---
layout: post
title: "difference of E1000 and VMXENT in Vmware Exsi"
date: 2016-06-14 15:18:55 +0800
comments: true
categories: vmware tools
---
Exsi中新建虚拟机网卡，可以选择四种网卡：E1000; 可变; VMXNET 2(增加型)；VMXENT 3

Vmware官网解释了区别:

要想兼容性好，就是用E1000,基本上所有的OS的带了E1000的驱动。

要想性能好(降低CPU的使用率)，那就用VMXNET 3，他是准虚拟化(ParaVirtualized)，需要在VM里面安装vmware的驱动(包含在vmware tools)，并且有一些限制，例如，虚拟机硬件版本必须是7以上，只有一些特定的操作系统被支持，

参考:

https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1001805
