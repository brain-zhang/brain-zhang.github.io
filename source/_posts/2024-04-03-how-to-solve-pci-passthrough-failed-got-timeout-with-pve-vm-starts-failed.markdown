---
layout: post
title: "How to solve 'PCI passthrough failed: got timeout' with PVE vm starts failed"
date: 2024-04-03 14:38:15 +0800
comments: true
categories: tools
---

PVE的虚机做了显卡直通后，有时候启动会报错:

```
start failed .... got timeout.
```

这一般是因为系统的内存不够了，因为硬件直通，虚拟机的内存需要跟物理内存的DMA映射一致，他就需要物理上连续的内存空间；如果此时物理机的空余内存看起来是够的，但是连续空间不够，就会报错；

<!-- more -->

解决方法有几个:

方法1. 比如我的机器是开启ZFS的ARC占用内存过多导致的，可以简单的执行下面的命令回收一下，可能内存就够了：

```
echo 3 > /proc/sys/vm/drop_caches
```

方法2. 如果通过1确定是ZFS的缓存导致内存占用过高，可以设置ZFS的最大缓存限制:

```
$ vim /etc/modprobe.d/zfs.conf


# ZFS tuning for a proxmox machine that reserves 8GB for ZFS
#
# Don't let ZFS use less than 4GB and more than 8GB
options zfs zfs_arc_min=4294967296
options zfs zfs_arc_max=8589934592
#
# disabling prefetch is no longer required
options zfs l2arc_noprefetch=0

```

上面的配置把ZFS的最大缓存占用限制在4GB-8GB之间；

然后执行下面命令重新生成内核，重启物理机器生效

```
$ update-initramfs -u
```

方法3. 上面两种方法都属于指标不治本，最直接有效的方法就是预先留下一定量的内存，只能给特定虚拟机使用，没有分配的话宁可一直闲着也不用；

这可以用Linux的hugepage机制来实现:

修改 `/etc/default/grub` 中的启动参数，加入

```
default_hugepagesz=1G hugepagesz=1G hugepages=128
```

比如我的机器，修改为

```
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
#GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction nofb textonly nomodeset video=efifb:off"
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream default_hugepagesz=1G hugepagesz=1G hugepages=128,multifunction nofb textonly nomodeset video=efifb:off"
GRUB_CMDLINE_LINUX=""
```
然后执行下面命令重新生成引导配置文件，最后重启物理机器生效

```
update-grub
```

重启后，系统会保留128G内存不用，如果要指定某台虚拟机使用，比如ID 121 虚拟机，请手工修改它的配置文件，加入hugepage参数:

```
$ vim /etc/pve/qemu-server/121.conf


...
hugepages: 1024
...
```

之后启动虚拟机，他就会从128G内存中分配它需要的内存；当然，这个虚拟机的内存是不能大于128GB的；
