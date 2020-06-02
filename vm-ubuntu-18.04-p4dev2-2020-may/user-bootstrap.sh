#!/bin/bash

# Print script commands and exit on errors.
set -xe

#Src 
BMV2_COMMIT="5bb6075d090e7cc9bbe2df36cf85a2f2635beb59"  # May 29, 2020
PI_COMMIT="0fbdac256151eb1537cd5ebf19101d5df60767fa"    # May 29, 2020
P4C_COMMIT="cf0e97ee08c36b0320c968fb4decf6a1984d2236"   # May 29, 2020
MININET_COMMIT="bfc42f6d028a9d5ac1bc121090ca4b3041829f86"  # May 29, 2020
PROTOBUF_COMMIT="v3.6.1"
GRPC_COMMIT="tags/v1.17.2"

#Get the number of cores to speed up the compilation process
NUM_CORES=`grep -c ^processor /proc/cpuinfo`

# --- Mininet --- #
git clone git://github.com/mininet/mininet mininet
cd mininet
git checkout ${MININET_COMMIT}
cd ..
sudo ./mininet/util/install.sh -nwv

# --- Protobuf --- #
git clone https://github.com/google/protobuf.git
cd protobuf
git checkout ${PROTOBUF_COMMIT}
export CFLAGS="-Os"
export CXXFLAGS="-Os"
export LDFLAGS="-Wl,-s"
./autogen.sh
./configure --prefix=/usr
make -j${NUM_CORES}
sudo make install
sudo ldconfig
unset CFLAGS CXXFLAGS LDFLAGS
# Force install python module
cd python
# Installing python module in this way seems to do so in a way on
# Ubuntu 18.04 that 'import google.protobuf.internal' fails, perhaps
# because it is "shadowed" in the default Python2 sys.path by
# google.rpc?  I am not sure.  As an attempted workaround, do not
# install the Python2 protobuf package this way, but instead do so
# later below using pip.
#sudo python setup.py install
cd ../..

# --- gRPC --- #
git clone https://github.com/grpc/grpc.git
cd grpc
git checkout ${GRPC_COMMIT}
git submodule update --init --recursive
export LDFLAGS="-Wl,-s"
make -j${NUM_CORES}
sudo make install
sudo ldconfig
unset LDFLAGS
cd ..
# Install gRPC Python Package
# grpcio 1.17.2 would be ideal, to match the version of gRPC that we
# have installed.  At least on 2020-Jan-21 when I tried to install
# that version of grpcio using pip, it indicated that many other
# versions were available, but not that one.  The closest two versions
# were 1.17.1 and 1.18.0.  Antonin Bas mentioned that he believes
# there were perhaps no changes from 1.17.1 to 1.17.2 and so
# recommended using 1.17.1.  So far, it has worked well when doing
# _basic_ P4Runtime API testing on a system on which this install
# script was run.
sudo -H pip install grpcio==1.17.1

sudo -H pip install protobuf==3.6.1

# --- BMv2 deps (needed by PI) --- #
git clone https://github.com/p4lang/behavioral-model.git
cd behavioral-model
git checkout ${BMV2_COMMIT}
patch -p1 < ~/behavioral-model-use-thrift-0.12.0.patch
./install_deps.sh
cd ..

# --- PI/P4Runtime --- #
git clone https://github.com/p4lang/PI.git
cd PI
git checkout ${PI_COMMIT}
git submodule update --init --recursive
./autogen.sh
./configure --with-proto
make -j${NUM_CORES}
sudo make install
sudo ldconfig
cd ..

# --- Bmv2 --- #
cd behavioral-model
./autogen.sh
./configure --enable-debugger --with-pi
make -j${NUM_CORES}
sudo make install
sudo ldconfig
# Simple_switch_grpc target
cd targets/simple_switch_grpc
./autogen.sh
./configure --with-thrift
make -j${NUM_CORES}
sudo make install
sudo ldconfig
cd ../../..


# --- P4C --- #
git clone https://github.com/p4lang/p4c
cd p4c
git checkout ${P4C_COMMIT}
git submodule update --init --recursive
mkdir -p build
cd build
cmake ..
# The command 'make -j${NUM_CORES}' works fine for the others, but
# with 2 GB of RAM for the VM, there are parts of the p4c build where
# running 2 simultaneous C++ compiler runs requires more than that
# much memory.  Things work better by running at most one C++ compilation
# process at a time.
make -j1
sudo make install
sudo ldconfig
cd ../..

# For some reason I do not know, the install of scapy via pip3 below
# fails unless these packages are installed first in a separate step.
# It seems like it should be the case that if they are required by the
# Python3 scapy package, that the command below would install them,
# too, but that seems not to be the case.
sudo -H pip3 install setuptools wheel

# Starting in 2019-Nov, the Python3 version of Scapy is needed for 'cd
# p4c/build ; make check' to succeed.
sudo -H pip3 install scapy==2.4.3

# --- Tutorials --- #
sudo -H pip install crcmod==1.7
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

# Do this last!
sudo reboot
