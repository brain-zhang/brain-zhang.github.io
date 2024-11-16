---
layout: post
title: "wsl best practice"
date: 2019-01-16 14:13:58 +0800
comments: true
categories: tools
---

WSL用了一年，感觉还不错。尤其是在我的机器上pypy3.5版本的`SHA512 pbkdf`计算性能竟然超越了原生Linux和Windows。成为Python运行效率最高的平台，实在是匪夷所思的事情。

WSL最让我满意的，是命令行里面可以结合Windows和Linux的命令行工具来管道处理，这个实在是太赞了。纯粹计算类的程序，Windows上面有很多现成的命令行工具，现在终于能:



```
ping.exe -t xxx.xxx.xxx.xxx|grep xxxx|echo -I xxx ~~~

```

这样来搞了，事实上，我自己写了很多Python脚本来处理Powershell自带的很多工具输出的内容，还有不少GPU运算程序大多数跑在Windows上面，能直接重定向到Linux上面实在太好了。

另外，WSL网络协议栈和Windows是共享的，倒是直接省了一个事，我直接把http_proxy配置成本地的shadowsock服务就很安逸的翻墙了；方便。

最后，就等着磁盘性能的改善了。

下面记一下常用的坑：

* 如果开机之后插拔一个移动硬盘，需要手工在WSL中执行重新挂载命令：


```
sudo umount /mnt/g && sudo mount -t drvfs "G:" /mnt/g

```


* WSL跟最新2019版本的卡巴斯基冲突，卡巴斯基默认会过滤所有HTTP流量

目前无解；要么禁用卡巴斯基的HTTP过滤功能，要么回退2018版本


最后，多个版本实验之后，锁定Win10 1709我也能连续3个月不关机了，稳定性可喜可贺。
