#!/bin/bash
set -e

APT_MIRROR="http://archive.raspberrypi.org"
NEXMON_COMMIT_HASH=5dbcbe524faaaa4866f8eaedf6345d2b7a82965b

apt-mark hold raspberrypi-kernel firmware-brcm80211
apt-get update
apt-get install -y \
    autoconf \
    bison \
    flex \
    gawk \
    git \
    libgmp3-dev \
    libtool \
    make \
    qpdf \
    texinfo

KERNEL_V=`dpkg -s raspberrypi-kernel | grep '^Version:' | sed -e 's/Version:\s*//'`
wget "${APT_MIRROR}/debian/pool/main/r/raspberrypi-firmware/raspberrypi-kernel-headers_${KERNEL_V}_armhf.deb" \
    -O /tmp/headers.deb
dpkg -i /tmp/headers.deb
rm -f /tmp/headers.deb

NEXMON_DIR=/tmp/nexmon
git clone git://github.com/seemoo-lab/nexmon.git ${NEXMON_DIR}
cd ${NEXMON_DIR}
git checkout ${NEXMON_COMMIT_HASH}

cd ${NEXMON_DIR}/buildtools/isl-0.10
./configure && make && make install
ln -s /usr/local/lib/libisl.so /usr/lib/arm-linux-gnueabihf/libisl.so.10

cd ${NEXMON_DIR}/buildtools/mpfr-3.1.4
autoreconf -f -i
./configure && make && make install
ln -s /usr/local/lib/libmpfr.so /usr/lib/arm-linux-gnueabihf/libmpfr.so.4

cd ${NEXMON_DIR}
source setup_env.sh
make

cd ${NEXMON_DIR}/utilities/nexutil
make && make install

# Raspberry Pi 3 and Zero W firmware
cd ${NEXMON_DIR}/patches/bcm43430a1/7_45_41_46/nexmon
make brcmfmac43430-sdio.bin
rm -f /lib/firmware/brcm/brcmfmac43430-sdio.bin
cp -f --preserve=mode brcmfmac43430-sdio.bin \
    /lib/firmware/brcm/brcmfmac43430-sdio.bin

# Raspberry Pi 3+ and 4
cd ${NEXMON_DIR}/patches/bcm43455c0/7_45_206/nexmon
make brcmfmac43455-sdio.bin
rm -f /lib/firmware/brcm/brcmfmac43455-sdio.bin
cp -f --preserve=mode brcmfmac43455-sdio.bin \
    /lib/firmware/brcm/brcmfmac43455-sdio.bin

# Kernel modules
make check-nexmon-setup-env
for p in /lib/modules/5.4.*; do
  if [ -e "${p}/build" ]; then
    make -C ${p}/build M=${PWD}/brcmfmac_5.4.y-nexmon -j2
    mkdir -p ${p}/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac
    mv -f brcmfmac_5.4.y-nexmon/brcmfmac.ko \
        ${p}/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko
    depmod -a `basename ${p}`
    make -C ${p}/build M=${PWD}/brcmfmac_5.4.y-nexmon -j2 clean
  fi
done

cd /
rm -rf ${NEXMON_DIR}

apt-get purge -y \
    autoconf \
    bison \
    flex \
    gawk \
    git \
    libgmp3-dev \
    libtool \
    make \
    qpdf \
    raspberrypi-kernel-headers \
    texinfo
apt-get autoremove -y
apt-get clean -y
