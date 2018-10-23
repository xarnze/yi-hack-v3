#!/bin/sh

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

if [ -d "/usr/yi-hack-v3" ]; then
	export LD_LIBRARY_PATH=/home/libusr:$LD_LIBRARY_PATH:/usr/yi-hack-v3/lib:/home/hd1/yi-hack-v3/lib
	export PATH=$PATH:/usr/yi-hack-v3/bin:/usr/yi-hack-v3/sbin:/home/hd1/yi-hack-v3/bin:/home/hd1/yi-hack-v3/sbin
elif [ -d "/home/yi-hack-v3" ]; then
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/lib:/home/yi-hack-v3/lib:/tmp/sd/yi-hack-v3/lib
	export PATH=$PATH:/home/base/tools:/home/yi-hack-v3/bin:/home/yi-hack-v3/sbin:/tmp/sd/yi-hack-v3/bin:/tmp/sd/yi-hack-v3/sbin
fi

hostname -F $YI_HACK_V3_PREFIX/yi-hack-v3/etc/hostname

if [[ $(get_config HTTPD) == "yes" ]] ; then
	lwsws -D
fi

if [[ $(get_config TELNETD) == "yes" ]] ; then
	telnetd
fi

if [[ $(get_config FTPD) == "yes" ]] ; then
	pure-ftpd -B
fi

if [[ $(get_config DROPBEAR) == "yes" ]] ; then
	dropbear -R
fi

if [ -f "/tmp/sd/yi-hack-v3/startup.sh" ]; then
	/tmp/sd/yi-hack-v3/startup.sh
elif [ -f "/home/hd1/yi-hack-v3/startup.sh" ]; then
	/home/hd1/yi-hack-v3/startup.sh
fi

# Adding some symlinks for the last picture/video
if [ ! -d "/home/yi-hack-v3/www/img" ]; then
	mkdir /home/yi-hack-v3/www/img
fi
if [ ! -f "/home/yi-hack-v3/www/img/last.jpg" ]; then
	ln -s /tmp/sd/record/last.jpg /home/yi-hack-v3/www/img/last.jpg
fi
if [ ! -f "/home/yi-hack-v3/www/img/last.mp4" ]; then
	ln -s /tmp/sd/record/last.mp4 /home/yi-hack-v3/www/img/last.mp4
fi

#Check if we use the telegram functionality
if [[ $(get_config ALARM) == "yes" ]] ; then
	if [ -f "/home/yi-hack-v3/script/alarm.sh" ]; then
		sh /home/yi-hack-v3/script/alarm.sh &
	fi
else
	if [ -f "/home/yi-hack-v3/script/last_motion.sh" ]; then
		sh /home/yi-hack-v3/script/last_motion.sh &
	fi
fi

