#!/bin/sh

# Copyright 2018 Vladimir Dronnikov
# Additional enhancements: Frank van der Stad
# GPL

CONF_FILE="/yi-hack-v3/etc/system.conf"

if [ -d "/usr/yi-hack-v3" ]; then
        YI_HACK_V3_PREFIX="/usr"
elif [ -d "/home/yi-hack-v3" ]; then
        YI_HACK_V3_PREFIX="/home"
fi

CAMERA_NAME=`more $YI_HACK_V3_PREFIX/yi-hack-v3/etc/hostname`;

photo() {
        cp $1 /tmp/sd/record/last.jpg
}

video() {
        cp $1 /tmp/sd/record/last.mp4
}

ALARM=0
while true; do
        test -r /tmp/sd/record/tmp.mp4.tmp && REC=1 || REC=0
        if [ "$REC" != "$ALARM" ]; then
                ALARM="$REC"
                [ "n$ALARM" == "n0" ] && rm /tmp/temp.jpg /tmp/temp.mp4
        fi
        [ -r /tmp/motion.jpg -a ! -r /tmp/temp.jpg ] && cp /tmp/motion.jpg /tmp/temp.jpg && echo JPG ready && photo /tmp/temp.jpg "Photo from $CAMERA_NAME"
        [ -r /tmp/motion.mp4 -a ! -r /tmp/temp.mp4 ] && cp /tmp/motion.mp4 /tmp/temp.mp4 && echo MP4 ready && video /tmp/temp.mp4 "Video from $CAMERA_NAME"
        sleep 1
done
