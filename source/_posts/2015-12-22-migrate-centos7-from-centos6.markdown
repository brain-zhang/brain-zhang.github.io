---
layout: post
title: "Migrate Centos7 from Centos6"
date: 2015-12-22 11:58:43 +0800
comments: true
categories: tools linux
---

工作环境切换到Centos7 半年有余，epel仓库里的软件版本比el6更新了不少，非常方便。

另外systemd的引入让很多程序，尤其是开机启动上，速度提升了不少。

总体来说，很多细节让你感觉很舒服，值得大家尽快切换到这个版本上了。

下面记一下从Centos6迁移到Centos7上 常见的Question:

Q: 为什么引入systemd 代替 SysV init，我就是习惯原来的 /etc/init.d/xxxx 的方法?
-------------------------------------------------------------------------------

A: 在我看来，有两点:

  1. 快。 真的是快，嗖嗖的快

  2. 日志。 终于能取代syslog了，我对syslog素无好感，配置复杂，level巨多，还不好排障。

参考资料:

http://www.ibm.com/developerworks/cn/linux/1407_liuming_init3/

https://wiki.archlinux.org/index.php/Systemd

Q: 为什么网卡名字这么奇怪，我要原来的简单明了的办法!!!
-------------------------------------------------------------------------------

A: 呃，好吧，我觉得虽然有一堆理由，但是网卡名字这个改变可能真的是没有产品经理的弊端。你想回到从前，很简单:

* 在 grub 加入 net.ifnames=0 and biosdevname=0 作为内核参数

* 在 /etc/sysconfig/network-scripts/ 内把你的网络卡配置文件换名为 ifcfg-ethX

* 假若你拥有多个界面并希望控制每个设备的名称，不想由内核作主，你似乎有必要通过 /etc/udev/rules.d/60-net.rules 盖过 /usr/lib/udev/rules.d/60-net.rules。

Q: grub.cfg 文件生成怎么这个奇怪，还要先配置 /etc/default/grub，再用命令生成一遍？我要直接改!!
-----------------------------------------------------------------------------------------------

A:  醒醒吧，我对这个改动双手赞成，至少她解决了centos6上一直被人诟病的efi问题。

Q: 嗯，我想问，ifconfig和 netstat哪里去了?
-----------------------------------------------------------------------------------------------

A: 额，套用官方原话回答吧:

ifconfig 及 netstat 工具程序在 CentOS 5 及 6 的应用手册内被置标为降级已接近十年，而 Redhat 决定在 CentOS 7 不会缺省安装 net-utils 组件。取而代之的工具是 ss 和 ip 。假如你真的、真的很需要 ifconfig 和 netstat，你可执行 yum install net-utils。


更多请参考：

https://wiki.centos.org/zh/FAQ/CentOS7#head-d04a9f331b47791774aefd7c11371934e7350ab3

