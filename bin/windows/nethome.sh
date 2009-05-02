#!/bin/bash
. /c/ssh-agent.log
ssh root@bhj3 perl -npe 's/^up/#up/' -i /etc/tinyproxy/tinyproxy.conf && ssh root@bhj3 /etc/init.d/tinyproxy restart&

netsh interface ip set address name=eth0 source=static addr=192.168.1.3 mask=255.255.255.0 gateway=192.168.1.1 gwmetric=1
netsh interface ip set dns name=eth0 source=static addr=202.106.0.20 register=primary
netsh interface ip add dns name=eth0 addr=202.106.196.115 index=2
#cygstart ~/bin/ieProxyDisable.reg
cd ~/doc
regedit /s MsnBlogProxyDisable.reg

