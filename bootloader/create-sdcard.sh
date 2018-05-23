#!/bin/bash

cat << EOM

################################################################################

This script will create a bootable SD card for wrlinux bsp fsl-imx6

The script must be run with root permissions

Example:
 $ sudo ./create-sdcard.sh /dev/sde

################################################################################

EOM

AMIROOT=`whoami | awk {'print $1'}`
if [ "$AMIROOT" != "root" ] ; then
	echo "	**** Error *** must run script with sudo"
	echo ""
	exit
fi

if [[ $# -ge 1 && (-b $1) ]]
then
	DRIVE=$1
else
	if [ $# -ge 1 ]
	then
		echo "$1 isn't block device, Please input correct dev blk"
	else
		echo "Not specify a blk device"
	fi

	exit
fi

lsblk $DRIVE
if [ $? != 0 ]
then
	echo "$DRIVER can't get blk information, Abort"
fi



SELECT_IS=0
while [ $SELECT_IS -ne 1 ]
do
	SELECT_IS=1
	read -p "Would you like to re-partition the drive anyways for $DRIVE [y/n] : " CASEPARTITION
	echo ""
	echo " "
	case $CASEPARTITION in
	"y")  echo " ";;
	"n")  echo "Skipping partitioning, Abort"; exit;;
	*)  echo "Please enter y or n";SELECT_IS=0;;
esac
done

SELECT_IS=0
while [ $SELECT_IS -ne 1 ]
do
	SELECT_IS=1
	read -p "Are you sure for formating $DRIVE [y/n] : " CASEPARTITION
	echo ""
	echo " "
	case $CASEPARTITION in
	"y")  echo "Now partitioning $DEVICEDRIVENAME ...";;
	"n")  echo "Abort"; exit;;
	*)  echo "Please enter y or n";SELECT_IS=0;;
esac
done

NUM_OF_DRIVES=`lsblk -l ${DRIVE} | grep -c ${DRIVE/\/dev\//}`

if [ "$NUM_OF_DRIVES" != "0" ]; then
	echo "Unmounting the $DRIVE drives"
	umount_list=`lsblk -l | grep  ${DRIVE/\/dev\//}[0-9] | cut -d " " -f 1`
	for i in $umount_list
	do
		echo "umount /dev/$i"
		umount -f /dev/$i 2> /dev/null
	done
fi

dd if=/dev/zero of=$DRIVE bs=1024 count=1024
sfdisk -u S -L $DRIVE << EOF
1000,144522,0x0C,*
160650,,,-
EOF

cat << EOM

################################################################################

		Partitioning Boot...

################################################################################
EOM
mkfs.vfat -F 32 -n "boot" ${DRIVE}${P}1

cat << EOM

################################################################################

		Partitioning rootfs, don't input anything, just wait a moment.... 

################################################################################
EOM
mkfs.ext3 -L "rootfs" ${DRIVE}${P}2

sync
sync
