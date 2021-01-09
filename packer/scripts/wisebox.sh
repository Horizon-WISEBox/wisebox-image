#!/bin/bash
set -e

apt-get install -y \
    bluez \
    bridge-utils \
    git \
    i2c-tools \
    isc-dhcp-server \
    libyaml-dev \
    lighttpd \
    python-dbus \
    python-smbus \
    python3-pip \
    tcpdump
apt-get remove -y wpasupplicant
apt-get autoremove -y
apt-get clean -y
pip3 install pipenv

chown -R root:root /wisebox-files
cp -fr --preserve=mode /wisebox-files/* /
rm -rf /wisebox-files
if [ -e "/etc/wisebox/wisebox.override.yml" ]; then
  rm -f /etc/wisebox/wisebox.yml
  mv /etc/wisebox/wisebox.override.yml /etc/wisebox/wisebox.yml
fi

usermod -l ${WB_USERNAME} pi
usermod -m -d /home/${WB_USERNAME} ${WB_USERNAME}
echo "${WB_USERNAME}:${WB_PASSWORD}" | chpasswd
mv /etc/sudoers.d/010_pi-nopasswd /etc/sudoers.d/010_${WB_USERNAME}-nopasswd
sed -i -e "s/pi/${WB_USERNAME}/" /etc/sudoers.d/010_${WB_USERNAME}-nopasswd

raspi-config nonint do_hostname "${WB_HOSTNAME}"
raspi-config nonint do_boot_wait 1
raspi-config nonint do_change_locale ${WB_LOCALE}
raspi-config nonint do_change_timezone ${WB_TIMEZONE}
echo "PRETTY_HOSTNAME=${WB_PRETTY_HOSTNAME}" > /etc/machine-info

sed -i \
    -e "s/WB_WIFI_COUNTRY/${WB_WIFI_COUNTRY}/" \
    -e "s/WB_ENABLE_SSH_SERVER/${WB_ENABLE_SSH_SERVER}/" \
    -e "s/WB_ENABLE_HW_CLOCK/${WB_ENABLE_HW_CLOCK}/" \
    /etc/init.d/wisebox-once.sh
systemctl enable wisebox-once.sh

if [ "${WB_ENABLE_HW_CLOCK}" -eq 1 ]; then
  echo "dtoverlay=i2c-rtc,ds3231" >> /boot/config.txt
  patch /lib/udev/hwclock-set /lib/udev/hwclock-set.patch
  apt-get -y remove fake-hwclock
  update-rc.d -f fake-hwclock remove
  systemctl disable fake-hwclock
fi
rm -f /lib/udev/hwclock-set.patch

WB_LOGGER_DIR=/tmp/logger
git clone git://github.com/Horizon-WISEBox/wisebox-logger.git ${WB_LOGGER_DIR}
cd ${WB_LOGGER_DIR}
git checkout ${WB_LOGGER_VERSION_TAG}
pipenv install --skip-lock --system --python 3.7
mv src/wisebox-logger.py /usr/local/bin
cd /
rm -rf ${WB_LOGGER_DIR}
ln -s /etc/wisebox/wisebox-logger.service \
    /etc/systemd/system/wisebox-logger.service
systemctl enable wisebox-logger.service

if [ "${WB_ENABLE_BLUETOOTH_NETWORKING}" -eq 1 ]; then
  patch /etc/bluetooth/main.conf /etc/bluetooth/main.conf.patch
  patch /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.patch
  echo bnep >> /etc/modules
  systemctl enable blueagent5.service
  systemctl enable bt-pan.service
fi
rm -f /etc/bluetooth/main.conf.patch
rm -f /etc/dhcp/dhcpd.conf.patch

WB_LOGSERVER_DIR=/tmp/logfile-server
patch /etc/lighttpd/conf-available/10-fastcgi.conf \
    /etc/lighttpd/conf-available/10-fastcgi.conf.patch
rm -f /etc/lighttpd/conf-available/10-fastcgi.conf.patch
ln -s /etc/lighttpd/conf-available/10-fastcgi.conf \
    /etc/lighttpd/conf-enabled/10-fastcgi.conf
git clone git://github.com/Horizon-WISEBox/wisebox-logfile-server.git \
    ${WB_LOGSERVER_DIR}
cd ${WB_LOGSERVER_DIR}
git checkout ${WB_LOGSERVER_VERSION_TAG}
pipenv install --skip-lock --system --python 3.7
mv src /var/www/web.py
rm -rf /var/www/html/*
mv static/* /var/www/html
cd /
rm -rf ${WB_LOGSERVER_DIR}
