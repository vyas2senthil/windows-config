#!/bin/bash

set -ex
test -e boot.img
git clean -xfd 
git co -- . 

unpackbootimg -i boot.img
mkdir ramdisk
cd ramdisk
cat ../boot.img-ramdisk.gz |gunzip |cpio -i 
cp ~/doc/superboot.sh .
cp ~/doc/superboot/ . -av
cat <<EOF > init.rc
service superuser /system/bin/sh /superboot.sh
        user root
        group root
	class main
	oneshot
EOF

mkbootfs . |gzip > ../boot.img-ramdisk.gz

cd ..

mkbootimg --kernel boot.img-zImage --base $(cat *-base) --pagesize $(cat *-pagesize) --ramdisk boot.img-ramdisk.gz -o boot.img

sudo env PATH=$PATH fastboot boot boot.img 

