#!/bin/bash -e

ARCH="arm64"
VERSION="debug"
TARGET_ROOTFS_DIR="binary"

if [ ! -d $TARGET_ROOTFS_DIR ] ; then
    sudo mkdir -p $TARGET_ROOTFS_DIR

    if [ ! -e ubuntu-base-18.04-base-arm64.tar.gz ]; then
        echo "\033[36m wget ubuntu-base-18.04-base-arm64.tar.gz \033[0m"
        wget -c http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.5-base-arm64.tar.gz
    fi

    sudo tar -xzvf ubuntu-base-18.04.5-base-arm64.tar.gz -C $TARGET_ROOTFS_DIR/
    sudo cp -b /etc/resolv.conf $TARGET_ROOTFS_DIR/etc/resolv.conf
    sudo cp -a /usr/bin/qemu-aarch64-static $TARGET_ROOTFS_DIR/usr/bin/
    sudo cp -b sources.list $TARGET_ROOTFS_DIR/etc/apt/sources.list

fi

finish() {
    ./ch-mount.sh -u $TARGET_ROOTFS_DIR
    echo -e "error exit"
    exit -1
}
trap finish ERR

echo "\033[36m Change root.....................\033[0m"

./ch-mount.sh -m $TARGET_ROOTFS_DIR

cat <<EOF | sudo chroot $TARGET_ROOTFS_DIR/

apt-get -y update
apt-get -f -y upgrade


apt install -y lubuntu-desktop
apt install -y sudo rsyslog wget gdb net-tools inetutils-ping openssh-server ifupdown alsa-utils python vim ntp git libssl-dev vsftpd tcpdump can-utils i2c-tools strace network-manager onboard evtest
apt install -y language-pack-zh-han* language-pack-en $(check-language-support) ibus-libpinyin language-pack-gnome-zh-hans gnome-getting-started-docs-zh-hk

apt install -y blueman
        echo exit 101 > /usr/sbin/policy-rc.d
        chmod +x /usr/sbin/policy-rc.d
        apt install -y blueman
        rm -f /usr/sbin/policy-rc.d

HOST=ubuntu-box

# Create User
useradd -G sudo -m -s /bin/bash ubuntu
passwd ubuntu <<IEOF
ubuntu
ubuntu
IEOF
gpasswd -a ubuntu video
gpasswd -a ubuntu audio
passwd root <<IEOF
root
root
IEOF

sync

EOF

./ch-mount.sh -u $TARGET_ROOTFS_DIR
echo -e "normal exit"

