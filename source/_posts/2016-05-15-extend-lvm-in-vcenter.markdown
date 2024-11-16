---
layout: post
title: "extend lvm in vCenter"
date: 2016-05-15 09:56:59 +0800
comments: true
categories: lvm tools
---

## 如何在vCenter上LVM分区扩容

* 导入镜像后，编辑虚拟机，增加第二块硬盘

* 这个时候我们执行下面命令就可以看到新加的磁盘

        ls -alh /dev/sdb

* 使用fdisk 创建lvm分区，方法和创建普通分区的方法一致，然后lvm的分区类型是8e

* 执行下面的命令看看效果，现在/dev/sdb1 已经是linux LVM类型的分区了

        fdisk -l

* 创建PV

        pvcreate /dev/sdb1
        pvdisplay

* 把PV加入VG中

        vgdisplay
        vgextend centos /dev/sdb1

* 扩容LV

        lvdisplay
        lvextend -L 150G  /dev/centos/opt
        xfs_growfs /dev/centos/opt

* df -h看一下，打完收工

* 如果再不够，可以加第三块盘，同样的操作
