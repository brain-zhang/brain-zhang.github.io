---
layout: post
title: "Fix LVM disks missing under /dev/xxx in PVE7.1"
date: 2023-03-20 11:06:10 +0800
comments: true
categories: tools
---

PVE7.1，重启后 LVM thinpool 丢掉了一块VM Disk；

解决方法:

```
lvchange -an storagename
vgchange -ay storagename
```

参考:

https://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg1807169.html
https://www.reddit.com/r/Proxmox/comments/ot6lfr/lvm_issues_after_upgrade_disks_missing_under/
