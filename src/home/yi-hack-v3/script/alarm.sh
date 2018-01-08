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

get_config()
{
        key=$1
        grep $1 $YI_HACK_V3_PREFIX$CONF_FILE | cut -d "=" -f2
}

TELEGRAM_BOT_TOKEN=$(get_config TELEGRAM_BOT_TOKEN)
TELEGRAM_CHAT_ID=$(get_config TELEGRAM_CHAT_ID)
TELEGRAM_SILENT=0

CAMERA_NAME=`more $YI_HACK_V3_PREFIX/yi-hack-v3/etc/hostname`;

curl() {
        LD_LIBRARY_PATH=/tmp/sd /tmp/sd/curl -k -q $@
}

photo() {
        cp $1 /tmp/sd/record/last.jpg
        curl -F photo="@$1" "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPhoto?chat_id=${TELEGRAM_CHAT_ID}&caption=$2&disable_notification=${TELEGRAM_SILENT}"
}

video() {
        curl -F video="@$1" "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendVideo?chat_id=${TELEGRAM_CHAT_ID}&caption=$2&disable_notification=${TELEGRAM_SILENT}"
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
