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

######################################################################
# Special Python2 installation steps for Ubuntu 20.04
######################################################################

# Several P4 open source projects still require Python 2 and PIP for
# Python 2.

# Ubuntu 20.04 is the first release to make Python3 the default
# version of Python, and while Python2 can still be installed, the
# method of doing so is different, as is installing the Python2
# version of pip.

# The python2 package installs python2 as the command
# /usr/bin/python2, but not as /usr/bin/python.  The package
# python-is-python2 installs python2 as /usr/bin/python.
apt-get install -y --no-install-recommends --fix-missing\
  wget \
  python2 \
  python-is-python2

# This appears to be official-looking documentation that recommends
# these steps for installing Python2 pip:
# https://pip.pypa.io/en/stable/installing/
wget https://bootstrap.pypa.io/get-pip.py
# When run as root, this installs pip executable in system-wide
# /usr/local/bin and /usr/local/lib/python2.7.  If run as non-root
# user, without sudo, it would instead install in the corresponding
# $HOME/.local/bin and $HOME/.local/lib/python2.7 directories, where
# $HOME is the home directory of the user that ran this script.
python get-pip.py


KERNEL=$(uname -r)
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get install -y --no-install-recommends --fix-missing\
  atom \
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
  python-psutil \
  python-setuptools \
  python3-pip \
  sublime-text \
  tcpdump \
  unzip \
  valgrind \
  vim \
  xcscope-el \
  xterm

# Noninteractive installation of wireshark is a bit unique.  The below
# is following instructions found in an answer on this web page:
# https://unix.stackexchange.com/questions/367866/how-to-choose-a-response-for-interactive-prompt-during-installation-from-a-shell
echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections
apt-get install -y --no-install-recommends --fix-missing wireshark

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
