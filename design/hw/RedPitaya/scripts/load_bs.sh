#!/usr/bin/bash

REDPITAYA="10.0.4.41"

BITSTREAM="$(find ../ -name *.bit)"
NAME="$(echo $BITSTREAM | sed -r 's/.*\/(.*.bit)$/\1/')"
echo $NAME

#sshpass -p 'root' scp $1 root@$REDPITAYA:/dev/xdevcfg
sshpass -p 'root' scp $BITSTREAM root@$REDPITAYA:/root/
sshpass -p 'root' ssh root@$REDPITAYA "cat /root/$NAME > /dev/xdevcfg"

# link: https://stackoverflow.com/questions/305035/how-to-use-ssh-to-run-a-shell-script-on-a-remote-machine

exit 0
