#! /bin/sh
### BEGIN INIT INFO
# Provides:        bs-init.sh
# Required-Start:    $all
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Load newest bitstream from directory.
# Description:       Load newest bitstream from directory.
### END INIT INFO

#attention, $HOME = '/' (on startup)
bitstream_dir="$HOME/root/"
target="/dev/xdevcfg"
bitstream_newest=$(ls -pt $bitstream_dir*.bit | head -1)

#load bitstream
cat $bitstream_newest > $target
