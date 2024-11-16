---
layout: post
title: "How to resize partition on Linux"
date: 2024-04-19 16:16:46 +0800
comments: true
categories: tools
---

之前操作Linux，扩容已有分区，一直是手工`fdisk`删除分区重建搞定的，这种方式不直观且容易出错；最近采用`parted`操作了以下，发现很直观；


比如我要对 /dev/sda1 从 100GB，扩容至200GB，操作如下

### 查看当前分区情况

```
# 进入 parted 工具
$ sudo parted
GNU Parted 3.4
Using /dev/sda
Welcome to GNU Parted! Type 'help' to view a list of commands.
# 查看磁盘信息
(parted) print /dev/sda
```

我只有 /dev/sda1 一个分区，因此很好办

### 根分区扩容

```
# 进入 parted 工具
$ sudo parted /dev/sda
# 查看磁盘信息
(parted) print
# 此时应该只有一个分区，直接扩展这个分区
(parted)resizepart 1
Warning: Partition /dev/sda1 is being used. Are you sure you want to continue?
# 直接输入 yes 确认
Yes/No? yes
# 输入新的结束点
# 这里输入的数值，就是上方输出中 Disk: 后方的数值
End?  [200GB]? 200GB
# 扩展完成之后退出 parted
(parted) quit
```


### 用resize2fs 工具扩展文件系统

```
$ sudo resize2fs /dev/sda1
```

不出意外，应该搞定了； 


### 注意事项

扩容之前，最好用 `lsof` 查看以下扩容分区，把所有的读写进程都停掉，如果条件允许，umount 这个分区再扩容，更加安全
