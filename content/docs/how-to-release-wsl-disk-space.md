---
title: How to Release WSL Disk Space
description: Guide on reclaiming disk space in WSL and Docker environments
weight: 30
categories: [documentation, wsl, docker]
tags: [wsl, docker, disk space, cleanup]
creationDate: 2026-03-14
lastUpdated: 2026-03-14
version: '1.0'
---

No space left on C:\\ !!!

If your C drive starts running low on disk space, and you are using WSL + docker there is a good chance docker is to
blame. Here a tip that can help you reclaim space on your system.

This will be done in two steps:

- Remove unused resources from docker
- Release WSL disk space back to host OS

<!--TOC-->

- [1. Remove unused resources from docker](#1-remove-unused-resources-from-docker)
- [2. Locating ext4.vhdx using PowerShell](#2-locating-ext4vhdx-using-powershell)
- [3. Release WSL disk space back to host OS](#3-release-wsl-disk-space-back-to-host-os)

<!--TOC-->

## 1. Remove unused resources from docker

To remove all stopped containers, dangling images, unused networks, and dangling build cache use

```bash
docker system prune [--all]
```

the `--all` flag will remove all unused data, like all stopped containers, images (Not attached to any container), and
all build cache.

The above command will still not remove any volumes. If you also want to remove unused volumes, that are not used by any
container, use the following command:

```bash
docker system prune --all --volumes
```

## 2. Locating ext4.vhdx using PowerShell

Open `regedit` and navigate to `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss`. You will find a list of sub-keys,
each representing a WSL distribution. Click on each sub-key and look for the `BasePath` value, which will give you the
path to the distribution's files, including the `ext4.vhdx` file.

## 3. Release WSL disk space back to host OS

WSL is not programmed to automatically shrink the virtual disk, only to grow. To reclaim the space on your drive follow
the following steps:

```powershell
# open powershell
wsl --shutdown
# it is recommended to backup your data before doing this operation, just in case
# you can copy the ext4.vhdx file to another location as backup
diskpart
# open window Diskpart, replace the path with the one of your ext4.vhdx file
select vdisk file="C:\{...}\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
```

Finally, delete the backup file if everything went well and you don't need it anymore
