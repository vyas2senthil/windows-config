#!/bin/bash

set -e
if test `whoami` = root; then
    echo 'You must not run this script as root!'
    exit -1
fi

sudo bash -c "cat <<EOF > /etc/apt/sources.list
deb http://192.168.0.46/ubuntu/ lucid main restricted universe multiverse
deb-src http://192.168.0.46/ubuntu/ lucid main restricted universe multiverse
deb http://192.168.0.46/ubuntu/ lucid-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu lucid-security main restricted universe multiverse
EOF"

sudo apt-get update
sudo apt-get install -y git-core ssh subversion vim


cd ~
git clone git://192.168.0.46/git/windows-config.git || (cd ~/windows-config && git pull)
cd ~/windows-config
git checkout -- . 
./bin/after-co-ln-s.sh
sudo apt-get install -y lftp
mkdir -p ~/external
ln -sf ~/external ~/bin/linux/ext
cd ~/bin/linux/ext
lftp -c "mirror -c http://192.168.0.46/google"
tar zxfv ./google/android-sdk_r06-linux_86.tgz
mkdir -p ~/external/bin/Linux/ext/android-sdk-linux_86/temp
cd ~/external/bin/Linux/ext/android-sdk-linux_86/temp
ln ../../google/* . 
. ~/.bashrc
~/external/bin/Linux/ext/android-sdk-linux_86/tools/android&
~/bin/linux/after-check-out.sh

echo 'OK, your configuration has completed!'
