#!/bin/bash

# Print commands and exit on errors
set -xe

# TBD: Update install steps for Sublime and Atom text editors for
# Ubuntu 18.04

apt-get update

KERNEL=$(uname -r)
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get install -y --no-install-recommends --fix-missing\
  autoconf \
  automake \
  bison \
  build-essential \
  ca-certificates \
  cmake \
  cpp \
  curl \
  emacs25 \
  flex \
  git \
  libboost-dev \
  libboost-graph-dev \
  libboost-iostreams-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libc6-dev \
  libfl-dev \
  libgc-dev \
  libgc1c2 \
  libgflags-dev \
  libgmp-dev \
  libgmp10 \
  libgmpxx4ldbl \
  libjudy-dev \
  libreadline-dev \
  libtool \
  libtool-bin \
  linux-headers-$KERNEL\
  llvm \
  lubuntu-desktop \
  make \
  net-tools \
  pkg-config \
  python \
  python-ipaddr \
  python-pip \
  python-ply \
  python-psutil \
  python-scapy \
  python-setuptools \
  python3-pip \
  tcpdump \
  unzip \
  valgrind \
  vim \
  xcscope-el \
  xterm

# TBD: Add these packages?
# g++
# zlib1g-dev

useradd -m -d /home/p4 -s /bin/bash p4
echo "p4:p4" | chpasswd
echo "p4 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_p4
chmod 440 /etc/sudoers.d/99_p4
usermod -aG vboxsf p4

cd /usr/share/lubuntu/wallpapers/
cp /home/vagrant/p4-logo.png .
rm lubuntu-default-wallpaper.png
ln -s p4-logo.png lubuntu-default-wallpaper.png
rm /home/vagrant/p4-logo.png
cd ~
sed -i s@#background=@background=/usr/share/lubuntu/wallpapers/1604-lubuntu-default-wallpaper.png@ /etc/lightdm/lightdm-gtk-greeter.conf

# Disable screensaver
apt-get -y remove light-locker

# Automatically log into the P4 user
cat << EOF | tee -a /etc/lightdm/lightdm.conf.d/10-lightdm.conf
[SeatDefaults]
autologin-user=p4
autologin-user-timeout=0
user-session=Lubuntu
EOF