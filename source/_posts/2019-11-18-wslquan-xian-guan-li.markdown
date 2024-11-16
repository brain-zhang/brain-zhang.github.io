---
layout: post
title: "WSL权限管理"
date: 2019-11-18 10:45:54 +0800
comments: true
categories: tools
---

重装系统，又折腾了一遍WSL环境，记录一下:

WSL (Win­dows Sub­sys­tem for Linux) 通过 /mnt 目录下的 c、d、e 等目录可分别访问本地的 C、D、E 等盘，虽然可以直接访问 Win­dows 下的文件内容，但输入 ls -al 查看文件你会发现文件权限全都是 777。这会导致一些问题出现，比如 Git会保留这些文件的执行权限，如果你之前在 Win­dows 下使用过 Git Bash ，那么在 WSL 中使用 `git status`查看本地仓库的文件状态时你会发现它们全部被标记成了 modified。

<!-- more -->

### 分析问题

首先要了解 WSL 中的两种文件系统：

#### VolFs
着力于在 Win­dows 文件系统上提供完整的 Linux 文件系统特性，通过各种手段实现了对 In­odes、Di­rec­tory en­tries、File ob­jects、File de­scrip­tors、Spe­cial file types 的支持。比如为了支持 Win­dows 上没有的 In­odes，VolFs 会把文件权限等信息保存在文件的 NTFS Ex­tended At­trib­utes 中。

WSL 中的 / 使用的就是 VolFs 文件系统。

#### DrvFs
着力于提供与 Win­dows 文件系统的互操作性。与 VolFs 不同，为了提供最大的互操作性，DrvFs 不会在文件的 NTFS Ex­tended At­trib­utes 中储存附加信息，而是从 Win­dows 的文件权限（Ac­cess Con­trol Lists，就是你右键文件 > 属性 > 安全选项卡中的那些权限配置）推断出该文件对应的的 Linux 文件权限。

所有 Win­dows 盘符挂载至 WSL 下的 /mnt 时都是使用的 DrvFs 文件系统。

简单来说就是 WSL 对 / 目录下的文件拥有完整的控制权，而 /mnt 目录中的文件无法被 WSL 完全控制（可修改数据，无法真实的修改权限）。WSL 对 /mnt 目录中权限的修改不会直接记录到文件本身，而在 Win­dows 下对文件权限的修改直接可作用到 WSL 。关于权限在[微软开发者博客中](https://p3terx.com/go/aHR0cHM6Ly9kZXZibG9ncy5taWNyb3NvZnQuY29tL2NvbW1hbmRsaW5lL2NobW9kLWNob3duLXdzbC1pbXByb3ZlbWVudHMv)有更详细的说明。

### 解决方案

这只是让文件在 WSL 中的权限看起来正常（目录 755，文件 644），实际并不会作用到 Win­dows 文件系统下的文件本身。

在 /etc/wsl.conf 中添加以下配置：

```
[automount]
enabled = true
root = /mnt/
options = "metadata,umask=22,fmask=111"
mountFsTab = true
```

上面的方法对所有盘符都有效，如果你想在 WSL 中调用 Win­dows 下的应用程序（比如 explorer.exe . 调用资源管理器打开当前路径）就需要对 C 盘进行单独设置，否则会提示没有权限。首先确认 wsl.conf 中的 mountFsTab 没有被设置为 false，然后编辑 /etc/fstab，添加如下内容：

```
C:\ /mnt/c drvfs rw,noatime,uid=1000,gid=1000,metadata,umask=22,fmask=11 0 0
```

此时执行`mkdir`等命令的时候，会发现新建的目录权限依然是 777。

目前民间解决方案是在.profile、.bashrc、.zshrc 或者其他 shell 配置文件中添加如下命令，重新设置 umask

```
[filesystem]
umask = 022
```

全部设置完成之后，最好重启一遍Windows系统。


#### 参考:

https://segmentfault.com/a/1190000016677670

https://p3terx.com/archives/problems-and-solutions-encountered-in-wsl-use-2.html
