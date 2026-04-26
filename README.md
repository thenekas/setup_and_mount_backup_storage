# LVM Backup Storage Setup

Automated script to provision a dedicated LVM logical volume for backup storage and mount it persistently via `/etc/fstab`.

## What it does

- Creates a GPT partition on a raw disk (if not exists)
- Creates or extends an LVM volume group
- Creates a logical volume and formats it as XFS
- Mounts it persistently via UUID in `/etc/fstab`

## Usage

1. Edit `setup_storage.conf` with your disk and volume details
2. Run:

```bash
sudo ./setup_storage.sh
```

## Config

| Variable | Description |
|----------|-------------|
| DEVICE | Raw block device e.g. `/dev/nvme0n5` |
| VG_NAME | LVM volume group name |
| LV_NAME | Logical volume name |
| LV_SIZE | Size e.g. `1.8G` |
| MOUNT_POINT | Where to mount e.g. `/backup` |
| FS_TYPE | Filesystem type e.g. `xfs` |

## Tested on

RHEL 9 / AWS EC2
