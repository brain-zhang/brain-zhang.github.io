---
layout: post
title: "Migrate PVE Storage From ZFS To Lvm"
date: 2023-01-18 10:21:13 +0800
comments: true
categories: tools
---

之前PVE的存储我用ZFS做了三个pool，一个RaidZ1，两个Raid0；

我的PVE内核版本为 `5.13.19-6-pve`;

实际用下来有一个大槽点；

就是对于12T以上的单盘，ZFS每次写入的时候都会炒豆子音大爆发，放在家里实在不是什么好体验；而且我一直有个困扰已久的问题没有解决；就是ZFS强壮是强壮；但是对于其dataset的管理方式，无论是send还是destroy，每个操作都会有长时间的卡顿lock；另外相对于读性能，不知道为什么，我的RaidZ1写性能一直没有达到单盘读写能力，我加了ARC、ZIL，各种方法都折腾了一遍，但是效果都不好；
还有一个最大的问题，就是虚拟机多了之后，比如我同时对20台虚拟机做硬盘迁移操作；ZFS的lock太严重了，比如我同时delete两个虚拟硬盘，必定lock timeout;这个lock timeout 60s的限制，没有找到设置的地方，只能硬改代码，非常tricky；而不用后台命令，PVE的web UI对于并行操作的支持不好，所以降低磁盘并行操作的locktime非常必要；

<!-- more -->

当然实际使用上，ZFS的优点也很突出:

* 透明压缩、文件去重；太有用了，尤其是PVE 创建LXC容器，文件存储直接继承ZFS的所有能力
* dataset级别的存储操作；这种块级别管理文件的方式，对于大规模数据迁移很有用，而且可以针对不同的需求对每一个dataset参数调整
* 快照；ZFS的杀手特性

总之折腾了一年多，我已经把ZFS的手册翻了好几遍了，我已经理解这个文件系统的使用方式了；

但是为了静音，我打算切换到PVE 源远流长的LVM存储管理；鉴于现在我的忘性越来越大，我想用尽可能简单的方式，来描述PVE如何使用LVM的；以后随时能扫一眼回忆回忆；


## 几句话过一下LVM

* LVM是整个一套管理磁盘存储的机制；包括分区扩容缩减，替换磁盘等等等等
* 一个物理磁盘称之为PhysicalStorageMedia
* LVM最底层的设备称之为PV(物理卷)， 物理卷可以是一组raid盘，可以是单个物理硬盘，可以是一个分区(比如/dev/sda1)
* 多个PV组成了VG(卷组)，一个VG对外表现就是一个块设备，就像一块硬盘一样
* 一个VG可以划分为多个LV(逻辑卷)；其表现就跟一块硬盘划分多个分区是一样的
* 有一种特殊的LV，称之为Thinly-Provisioned Logical Volumes(精简模式LVM)；
* thin LV支持COW(快照方便)和动态存储分配空间(按需分配而不是虚拟之指定的磁盘大小，节约空间)，跟ZFS一样，适合云环境
* 创建thinLV之前，必须先创建一个thinpool，次序依次是 创建PV->创建VG->在此VG上创建thinpool->在此thinpool上创建thin LV；
* LVM可以动态缩减空间，增删硬盘
* 一个VG可以单个PV，也可以多个PV组成
* 一个VG可以包含多个thinpool+多个普通LV
* VG可以动态扩展，空间可以动态调整
* LV空间可以动态调整

## PVE中的LVM

* PVE上后台用命令行可以支持所有LVM特性
* PVE Web界面功能比较弱，只支持
  - 将一个PV划分为一个VG
  - 将一个VG划分为一个thinpool，即lvm-thin
  - Web UI不可以组合划分

参考了一篇非常详细的文章，人家写的很清楚，就不啰嗦了:

https://codeantenna.com/a/SG6LHk1x9s


## 规划

* 三块硬盘，分成三个VG
* 两个VG做成thin pool，只有lvm thin，分别用于存储LXC容器和VM
* 一个VG 用来做文件服务器
