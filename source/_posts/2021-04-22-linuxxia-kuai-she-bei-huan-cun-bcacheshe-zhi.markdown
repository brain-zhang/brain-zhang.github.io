---
layout: post
title: "Linux下块设备缓存Bcache设置"
date: 2021-04-22 10:04:17 +0800
comments: true
categories: tools
---

## Bcache简介

Bcache是Linux内核块设备层cache，支持多块HDD使用同一块SSD作为缓存盘。它让SSD作为HDD的缓存成为了可能。由于SSD价格昂贵，存储空间小，而HDD价格低廉，存储空间大，因此采用SSD作为缓存，HDD作为数据存储盘，既解决了SSD容量太小，又解决了HDD运行速度太慢的问题。

Bcache是从Linux-3.10开始正式并入内核主线的，因此，要使用Bcache，需要将内核升级到3.10及以上版本才行。

<!-- more -->


## Bcache缓存策略

Bcache支持三种缓存策略，分别是：writeback、writethrough、writearoud，默认使用writethrough，缓存策略可动态修改。

* writeback 回写策略：回写策略默认是关闭的，如果开启此策略，则所有的数据将先写入缓存盘，然后等待系统将数据回写入后端数据盘中。

* writethrough 写通策略：默认的就是写通策略，此模式下，数据将会同时写入缓存盘和后端数据盘。

* writearoud ：选择此策略，数据将直接写入后端磁盘。


Write-misses写缺失(写入的数据不在缓存中)有两种处理方式：

    * Write allocate方式将写入位置读入缓存，然后采用write-hit（缓存命中写入）操作。写缺失操作与读缺失操作类似。

    * No-write allocate方式并不将写入位置读入缓存，而是直接将数据写入存储。这种方式下，只有读操作会被缓存。

无论是Write-through还是Write-back都可以使用写缺失的两种方式之一。只是通常Write-back采用Write allocate方式，而Write-through采用No-write allocate方式；因为多次写入同一缓存时，Write allocate配合Write-back可以提升性能；而对于Write-through则没有帮助。

## 安装

```
sudo apt-get update
sudo apt-get install bcache-tools
```

## 操作

假设我们的HDD设备为/dev/sdb， SSD设备为/dev/sdc，我们需要用SSD加速HDD

#### 擦除磁盘中的超级块信息

```
# wipefs -a /dev/sdb
# wipefs -a /dev/sdc
```

#### 创建后端磁盘(HDD)

```
make-bcache -B /dev/sdb
```

#### 创建缓存盘(SSD)

```
make-bcache -C /dev/sdc  -b1M --writeback
```

#### 添加缓存盘

要为bcache后端磁盘添加缓存盘，在创建缓存盘成功之后，首先需要获取该缓存盘的cset.uuid

```
# ls /sys/fs/bcache/
5d9e80f1-e4b7-48f5-ace2-f2f391877ea7

# bash -c 'echo 5d9e80f1-e4b7-48f5-ace2-f2f391877ea7 > /sys/block/bcache0/bcache/attach'
```

注意，写入UUID必须以root身份才能执行，在zsh里面sudo可能会出现权限不够的问题，所以直接用`bash -c`来做

#### 看一下块设备结构

```
# lsblk

sdb         8:16   0 1000G  0 disk
└─bcache0 251:0    0 1000G  0 disk
sdc         8:32   0  300G  0 disk
└─bcache0 251:0    0 1000G  0 disk

ls /sys/block/sdb/bcache/dev/slaves
```

#### 查看缓存模式

```
# cat /sys/block/bcache0/bcache/cache_mode

[writethrough] writeback writearound none

```

#### 更改缓存模式

```
# echo writeback > /sys/block/bcache0/bcache/cache_mode
# cat /sys/block/bcache0/bcache/cache_mode

writethrough [writeback] writearound none

```

#### 查看缓存数据量

```
# cat /sys/block/bcache0/bcache/dirty_data

4.1G
```


#### 格式化、挂载

```
# mkfs.ext4 /dev/bcache0
# mount /dev/bcache0 /opt
```

#### 开机自动挂载

```
echo "/dev/bcache0 /opt ext4 rw 0 0" >> /etc/fstab
```

#### 测试性能

```
# fio -filename=/dev/sdb -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=mytest
```

## 停用Bcache

#### 卸载

```
umount /dev/bcache0
```

#### 注销缓存盘

```
echo 1 >/sys/fs/bcache/5d9e80f1-e4b7-48f5-ace2-f2f391877ea7/unregister
```

#### 停用后端磁盘

```
echo 1 > /sys/block/bcache0/bcache/stop
```

#### 操作完成后，通过lsblk命令查看结果

```
# lsblk /dev/sdb
```

停用之后，后端磁盘的数据是不会丢的，只不过加速功能没有了；当然，注销缓存盘的时候，缓存盘不能有数据读写操作

## 参考

https://wiki.ubuntu.com/ServerTeam/Bcache

https://askubuntu.com/questions/523817/how-to-setup-bcache

https://markrepo.github.io/maintenance/2018/09/10/bcache/

