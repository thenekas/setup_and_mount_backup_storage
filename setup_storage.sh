#!/bin/bash

if [ "$EUID" -ne 0 ]; then
        echo "Please start the script with sudo privileges"
        echo "sudo setup_storage.sh"
        exit 1
fi

CONF="$(dirname "$0")/backup_storage.conf"
source "$CONF"

if [ ! -b "$DEVICE" ]; then
	echo "Device $DEVICE not found"
	echo "Please check that you have avaliable disk for backup mount"
	exit 1
fi

PARTITION="${DEVICE}p1"

if ! lsblk "$PARTITION" &>/dev/null; then
	echo "Creating partition on $DEVICE"
	parted -s "$DEVICE" mklabel gpt mkpart primary 0% 100% set 1 lvm on
	partprobe "$DEVICE"
fi

if ! pvs "$PARTITION" &>/dev/null; then
	echo "Creating physical volume on $PARTITION..."
	pvcreate "$PARTITION"
fi

if ! vgs "$VG_NAME" &>/dev/null; then
	echo "Creating volume group $VG_NAME.."
	vgcreate "$VG_NAME" "$PARTITION"

else
	echo "Adding $PARTITION to existing VG $VG_NAME..."
	vgextend "$VG_NAME" "$PARTITION"
fi

if ! lvs "/dev/$VG_NAME/$LV_NAME" &>/dev/null; then
	echo "Creating logical volume $LV_NAME..."
	lvcreate -L "$LV_SIZE" -n "$LV_NAME" "$VG_NAME"
	mkfs.xfs "/dev/$VG_NAME/$LV_NAME"
fi

mkdir -p "$MOUNT_POINT"

UUID=$(blkid -s UUID -o value "/dev/$VG_NAME/$LV_NAME")

if ! grep -q "$UUID" /etc/fstab; then
	echo "UUID=$UUID $MOUNT_POINT $FS_TYPE defaults 0 2" >> /etc/fstab
	echo "Added to fstab"
fi

systemctl daemon-reload
mount -a

echo "Done. $MOUNT_POINT is mounted and persistent via fstab"

df -h "$MOUNT_POINT"
