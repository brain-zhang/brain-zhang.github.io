---
layout: post
title: "WSL环境备份恢复"
date: 2019-11-18 11:04:27 +0800
comments: true
categories: tools
---

WSL环境是可以单独备份还原的，有个工具名为LxRunOffline:

https://github.com/DDoSolitary/LxRunOffline

release版本下载下来之后直接使用就可以；记录一下操作命令:

<!-- more -->

#### 备份wsl

```
LxRunOffline.exe export -n Ubuntu-18.04 -f ubuntu18.04.backup.tar.gz
```

-n ：wsl的别名，就是之前用list查看的其中一个

-f ：备份的路径，我这直接备份到当前路径backup.tar.gz

#### 还原wsl

```
LxRunOffline.exe install -n Ubuntu-18.04 -d C:\wsl -f D:\temp\ubuntu18.04.backup.tar.gz
```

-n ：起个名字

-d ：wsl安装目录

-f ：备份文件目录

#### 删除WSL环境

可以直接用wsl原生的命令：wslconfig

```
wslconfig /u Ubuntu-18.04
```
