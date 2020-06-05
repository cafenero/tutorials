#!/bin/bash

# Print script commands and exit on errors.
set -xe

#Src 
BMV2_COMMIT="5bb6075d090e7cc9bbe2df36cf85a2f2635beb59"  # May 29, 2020
PI_COMMIT="0fbdac256151eb1537cd5ebf19101d5df60767fa"    # May 29, 2020
P4C_COMMIT="cf0e97ee08c36b0320c968fb4decf6a1984d2236"   # May 29, 2020
MININET_COMMIT="bfc42f6d028a9d5ac1bc121090ca4b3041829f86"  # May 29, 2020
PROTOBUF_COMMIT="v3.2.0"
GRPC_COMMIT="v1.3.2"

#Get the number of cores to speed up the compilation process
NUM_CORES=`grep -c ^processor /proc/cpuinfo`

# --- Mininet --- #
#git clone git://github.com/mininet/mininet mininet
#cd mininet
#git checkout ${MININET_COMMIT}
#cd ..
#sudo ./mininet/util/install.sh -nwv

# --- Protobuf --- #
#git clone https://github.com/google/protobuf.git
#cd protobuf
#git checkout ${PROTOBUF_COMMIT}
#export CFLAGS="-Os"
#export CXXFLAGS="-Os"
#export LDFLAGS="-Wl,-s"
#./autogen.sh
#./configure --prefix=/usr
#make -j${NUM_CORES}
#sudo make install
#sudo ldconfig
#unset CFLAGS CXXFLAGS LDFLAGS
## Force install python module
#cd python
#sudo python setup.py install
#cd ../..

# --- gRPC --- #
#git clone https://github.com/grpc/grpc.git
#cd grpc
#git checkout ${GRPC_COMMIT}
#git submodule update --init --recursive
#export LDFLAGS="-Wl,-s"
#make -j${NUM_CORES}
#sudo make install
#sudo ldconfig
#unset LDFLAGS
#cd ..
# Install gRPC Python Package
# As of 2020-May-28 on an Ubuntu 16.04 system, attempting 'sudo pip
# install grpcio==1.3.2' gave an error that version 1.3.2 could not be
# found, and a list of versions, of which the closest two to 1.3.2
# were 1.3.0 and 1.3.3.

# Installing grpcio 1.3.3 causes 'cd exercises/basic ; cp
# solutions/basic.p4 . ; make run' to fail with this as part of the
# error message, not including the stack trace:
# AttributeError: 'module' object has no attribute 'UnaryUnaryClientInterceptor'

# I experimented with grpcio versions up through 1.10.0, and 1.8.1 was
# the smallest version number I found that enabled the basic.p4
# tutorial to pass packets successfully.
sudo pip install grpcio==1.8.1

# --- BMv2 deps (needed by PI) --- #
#git clone https://github.com/p4lang/behavioral-model.git
#cd behavioral-model
#git checkout ${BMV2_COMMIT}
# From bmv2's install_deps.sh, we can skip apt-get install.
# Nanomsg is required by p4runtime, p4runtime is needed by BMv2...
#tmpdir=`mktemp -d -p .`
#cd ${tmpdir}
#bash ../travis/install-thrift.sh
#bash ../travis/install-nanomsg.sh
#sudo ldconfig
#bash ../travis/install-nnpy.sh
#cd ..
#sudo rm -rf $tmpdir
#cd ..

# --- PI/P4Runtime --- #
#git clone https://github.com/p4lang/PI.git
#cd PI
#git checkout ${PI_COMMIT}
#git submodule update --init --recursive
#./autogen.sh
#./configure --with-proto
#make -j${NUM_CORES}
#sudo make install
#sudo ldconfig
#cd ..

# --- Bmv2 --- #
#cd behavioral-model
#./autogen.sh
#./configure --enable-debugger --with-pi
#make -j${NUM_CORES}
#sudo make install
#sudo ldconfig
# Simple_switch_grpc target
#cd targets/simple_switch_grpc
#./autogen.sh
#./configure --with-thrift
#make -j${NUM_CORES}
#sudo make install
#sudo ldconfig
#cd ../../..


# --- P4C --- #
#git clone https://github.com/p4lang/p4c
#cd p4c
#git checkout ${P4C_COMMIT}
#git submodule update --init --recursive
#mkdir -p build
#cd build
#cmake ..
# The command 'make -j${NUM_CORES}' works fine for the others, but
# with 2 GB of RAM for the VM, there are parts of the p4c build where
# running 2 simultaneous C++ compiler runs requires more than that
# much memory.  Things work better by running at most one C++ compilation
# process at a time.
#make -j1
#sudo make install
#sudo ldconfig
#cd ../..

# For some reason I do not know, the install of scapy via pip3 below
# fails unless I do this first.
sudo -H pip3 install setuptools wheel

# Starting in 2019-Nov, the Python3 version of Scapy is needed for 'cd
# p4c/build ; make check' to succeed.
sudo -H pip3 install scapy==2.4.3

# --- Tutorials --- #
#sudo pip install crcmod==1.7
git clone https://github.com/p4lang/tutorials
sudo mv tutorials /home/p4
sudo chown -R p4:p4 /home/p4/tutorials

# --- Emacs --- #
sudo cp p4_16-mode.el /usr/share/emacs/site-lisp/
sudo mkdir /home/p4/.emacs.d/
echo "(autoload 'p4_16-mode' \"p4_16-mode.el\" \"P4 Syntax.\" t)" > init.el
echo "(add-to-list 'auto-mode-alist '(\"\\.p4\\'\" . p4_16-mode))" | tee -a init.el
sudo mv init.el /home/p4/.emacs.d/
sudo ln -s /usr/share/emacs/site-lisp/p4_16-mode.el /home/p4/.emacs.d/p4_16-mode.el
sudo chown -R p4:p4 /home/p4/.emacs.d/

# --- Vim --- #
cd ~  
mkdir .vim
cd .vim
mkdir ftdetect
mkdir syntax
echo "au BufRead,BufNewFile *.p4      set filetype=p4" >> ftdetect/p4.vim
echo "set bg=dark" >> ~/.vimrc
sudo mv ~/.vimrc /home/p4/.vimrc
cp ~/p4.vim syntax/p4.vim
cd ~
sudo mv .vim /home/p4/.vim
sudo chown -R p4:p4 /home/p4/.vim
sudo chown p4:p4 /home/p4/.vimrc

# --- Adding Desktop icons --- #
DESKTOP=/home/${USER}/Desktop
mkdir -p ${DESKTOP}

cat > ${DESKTOP}/Terminal << EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Terminal
Name[en_US]=Terminal
Icon=konsole
Exec=/usr/bin/x-terminal-emulator
Comment[en_US]=
EOF

cat > ${DESKTOP}/Wireshark << EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Wireshark
Name[en_US]=Wireshark
Icon=wireshark
Exec=/usr/bin/wireshark
Comment[en_US]=
EOF

cat > ${DESKTOP}/Sublime\ Text << EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Sublime Text
Name[en_US]=Sublime Text
Icon=sublime-text
Exec=/opt/sublime_text/sublime_text
Comment[en_US]=
EOF

sudo mkdir -p /home/p4/Desktop
sudo mv /home/${USER}/Desktop/* /home/p4/Desktop
sudo chown -R p4:p4 /home/p4/Desktop/

# Make the P4 logo look normal size in center of desktop, not
# stretched in odd way.

TMPF=/tmp/lubuntu.tmp
cat > ${TMPF} << EOF
[*]
wallpaper_mode=center
wallpaper_common=1
wallpapers_configured=1
wallpaper0=/usr/share/lubuntu/wallpapers/lubuntu-default-wallpaper.png
wallpaper=/usr/share/lubuntu/wallpapers/lubuntu-default-wallpaper.png
desktop_bg=#2e4060
desktop_fg=#ffffff
desktop_shadow=#000000
desktop_font=Ubuntu 11
show_wm_menu=0
sort=mtime;ascending;
show_documents=0
show_trash=1
show_mounts=1
EOF
sudo mkdir -p /home/p4/.config/pcmanfm/lubuntu
sudo mv ${TMPF} /home/p4/.config/pcmanfm/lubuntu/desktop-items-0.conf
sudo chown -R p4:p4 /home/p4/.config/

# Do this last!
sudo reboot
