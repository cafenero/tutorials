#!/bin/bash

# Print commands and exit on errors
set -xe

# Followed Ubuntu instructions for installing Sublime text editor
# retrieved from the following web page on 2020-Jun-02:
# https://www.sublimetext.com/docs/3/linux_repositories.html
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
apt-get install -y apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" > /etc/apt/sources.list.d/sublime-text.list
# The following commands are done later below:
#apt-get update
#apt-get install sublime-text

# Followed Ubuntu instructions for installing Atom text editor
# retrieved from the following web page on 2020-Jun-02:
# https://flight-manual.atom.io/getting-started/sections/installing-atom/#platform-linux
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | apt-key add -
echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list
# The following commands are done later below:
#apt-get update
#apt-get install atom

apt-get update

KERNEL=$(uname -r)
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get install -y --no-install-recommends --fix-missing\
  atom \
  ca-certificates \
  curl \
  git \
  lubuntu-desktop \
  python \
  python-dev \
  python-ipaddr \
  python-pip \
  python-psutil \
  python-scapy \
  python-setuptools \
  python3-pip \
  sublime-text \
  unzip \
  vim \
  wireshark \
  wget \
  xterm

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
