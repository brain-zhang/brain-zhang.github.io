---
layout: post
title: "migrate vm instances and snapshots from different vps supporters or accounts"
date: 2018-07-21 09:11:55 +0800
comments: true
categories: tools
---

虽然已经进入X时代了，但电脑城装机习惯性还是用Ghost，无他，习惯方便。

Linux上面系统迁移，网上搜一搜，大批文章还是原始的dd, rsync之类；当然，不是说他不行，而是面向小白实在是有点坑啊。

云时代，不同厂商间基本都提供了`快照`+`在线热迁移`的方案了，用起来也很舒服。

那么，作为一个VPS小白用户，怎么在不同的账号，或者说不同的厂商之间，迁移我的Linux系统呢？

比如我在vultr上面有两个账号，vultr的快照功能是很赞的，免费、速度快、生成虚机靠谱；

那么问题来了，怎么把账号A的Linux A迁移到账号B的Linux B虚机上呢？

官方回复是还没有考虑这个功能，然后Linux怎么可能做不到这种简单的事情呢？当然立刻就有人回复了详细的搞法，还贴心的附录了视频:

https://discuss.vultr.com/discussion/104/snapshot-image-downloads/p2

<!-- more -->

#### 我们也嘴炮一下整个过程:

1. 对Linux A建立SnapShot A

2. 从SnapShot A创立一台虚机 (注意这台虚机的磁盘要比Linux A的磁盘大，比如Linux A是5$的套餐15GB，那么最好建立一个20$的套餐45GB)

3. vultr 有挂载光盘的功能，可以挂载一个linux live CD,用这张Live CD启动新虚机

4. dd 命令完全拷贝原有磁盘

    dd if=/dev/vtbd0 bs=1m | gzip -c | ssh -e none myolduser@myoldserverip 'cat > backupsnapshot.iso.gz'

5. 账号B开一台虚机，把backupsnapshot.iso.gz拷贝过去

6. 同样挂载Live CD，反向dd，恢复文件系统

7. 重启，改配置，赋权限，搞定


说是嘴炮，是因为我之前硬盘dd对拷过，对于速度和之后的配置兼容深为烦恼，更不用说KVM上面用这个招数去做迁移了，我一个坑都不想踩的。

光是看看上面一波操作，我就没兴趣折腾了。当然也有很多人的乐趣就是折腾，但是年纪大了就老是想偷懒。

之前在不同物理机之间做Linux迁移，用clonezilla居多，虽然有一些Raid方面的支持会有问题，总体来说我对它的稳定性和便利性有巨大信任，但从来没有在KVM上搞过，这次我完整实验了一把，效果MAX。

#### 下面我们说说怎么用clonezilla把上面繁琐的手工操作搞得不那么痛苦一点:

1. 先去clonezilla.org 官网，找到下载地址，好吧，我已经帮你找好了:

    http://onet.dl.osdn.jp/clonezilla/69273/clonezilla-live-2.5.5-38-amd64.iso

2. vultr很贴心的提供了从url上传镜像的功能，我们到下面这个功能项中把iso镜像的url填进去，添加clonezilla镜像文件到vultr:

    https://my.vultr.com/iso/add/

3. 点开虚机Linux A，点击`Settings` -> `Custom ISO` -> 选择clonezilla -> 点击 `Attach ISO and Reboot`

4. 用VNC连接虚机，进入clonezilla的界面

5. 进入菜单项，`第一菜单800X600分辨率` -> `简体中文` -> `使用再生龙`

6. 选择 `remote-source 进入远程设备克隆的源端`

7. 选择 `初学模式：接受默认的选择`

8. 选择 `复制本机硬盘到它机硬盘`

9. 选择 `设定固定IP地址`

10. 设定IP,子网掩码，网关,域名服务器，如果机器有多块网卡的话，一般会列出网卡名字和MAC地址供你选择，vultr一般是双网卡(如果你启用了内网地址的话),网络信息在vultr的主机settings中能查到。

11. 选择要克隆的硬盘，设定没有问题的话，下面一路YES下去，机器就会进入等待目标端连接的状态

12. 在账号B的Linux B中重复1-11步操作，不同的是第6步选择目标端，第8步选择 `从镜像文件恢复至本机硬盘`, 之后填入Linux A的IP地址，就可以开始克隆对拷了

13. 我在不同vultr的账号中测试了Ubuntu16.04, Centos7.1, FreeBSD 10的迁移，效果MAX


看起来步骤不少，熟练了还是能迅速操作的，clonezilla赞一个


#### 一点小ToolTIps:

* 这个方法其实可以适用所有KVM虚机迁移，所以只要服务商开了自定义镜像挂载的功能，都可以跨公网对拷

* 如果A和B不能直接通信的话，可以开一台中转机器C，在Linux A的一端把硬盘 clone为镜像文件，通过SSH文件服务器的方式转存到C上，然后在B上连接SSH文件服务器C，从而还原系统; 提示一下，其实生成的镜像文件挺小的，比dd之后压缩还小的多

* 如果clone的时候报错，一般是A 端的文件系统有损坏，这个时候可以简单的执行 `shutdown -rF now` ,重启后自动修复一把，之后再挂载clonezilla ISO进行克隆


#### 最后，让我们期望所有的服务商都能提供 qcow2 的导入导出功能


