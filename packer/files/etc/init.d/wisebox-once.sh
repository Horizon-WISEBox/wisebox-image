#!/bin/sh
### BEGIN INIT INFO
# Provides:          wisebox-once.sh
# Required-Start:
# Required-Stop:
# Default-Start: 3
# Default-Stop:
# Short-Description: Performs WISEBox initialisation tasks
# Description:
### END INIT INFO
. /lib/lsb/init-functions
case "$1" in
  start)
    log_daemon_msg "Starting wisebox-once.sh"
    update-rc.d wisebox-once.sh remove &&
    if [ "WB_ENABLE_SSH_SERVER" -eq 1 ]; then
      raspi-config nonint do_ssh 0
    fi &&
    sudo iw reg set WB_WIFI_COUNTRY &&
    rfkill unblock wifi &&
    for filename in /var/lib/systemd/rfkill/*:wlan ; do
      echo 0 > $filename
    done &&
    if [ "WB_ENABLE_HW_CLOCK" -eq 1 ]; then
      raspi-config nonint do_i2c 0
    fi &&
    rm /etc/init.d/wisebox-once.sh &&
    log_end_msg $?
    reboot
    ;;
  *)
    echo "Usage: $0 start" >&2
    exit 3
    ;;
esac
