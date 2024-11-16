---
layout: post
title: "从WebAssembly说开去"
date: 2018-08-25 11:14:39 +0800
comments: true
categories: develop
---

科技界历史循环，轨迹无法量化预测。

前几天看到bellard都在浏览器里面用WebAssembly跑虚拟机了，点进去试试，竟然模拟Win2000都有模有样了。

https://bellard.org/jslinux/index.html

不由得感叹人折腾的能力真是无比强大。

<!-- more -->


有人说WebAssembly又实现了一个Flash，又实现了一个SliverLight，又造了一个JavaApplet，我都想到很久很久之前的ActiveX了，想到COM组件了~~~

肯定又会有人跳出来说，这回不一样了:

1. 谷歌、苹果、微软等公司一起来干了

2. 前端拯救世界，前端用Nodejs打入后端，后端用WebAssembly征服前端~~

3. 就连技术媒体都开始用吸睛标题：<WebAssembly:解决 JavaScript 痼疾的一颗银色子弹？>

我得说，技术路线的发展完全是随机的，无迹可寻。

* 比如当初Flash就被乔帮主活活说死了，说你不行行也不行。

* 比如Plan9搞了一堆创新之后死翘翘了，根本就没几个人去在意

* 比如苦大仇深的GUI方案，MS推出了一系列库，从MFC、WTL到所谓的WPF，从各类公司的私有解决方案，到现在还在服役的大名鼎鼎的Duilib;最后就不提历史风尘中的各类商业皮肤库了；

     还有开源界的各路GNome、wxWidgets、QT、TCL，到现在跨平台GUI方案的战火都烧到浏览器上了，VS Code用啥实现的，竟然是Electron；虽然效果拔群，但是总觉得哪里不对路啊；

* 从移动手机刚刚兴起的年代，就有无数种解决方案发誓要做到"一次编写，到处运行"，兼容各大主流移动平台；如今看看，口号依旧，分裂依旧，半死不活依旧

* 为什么历史选择TCP/IP而把ISO模型扫进教科书

* 为什么IE打败Netscape

* 为什么KVM逐渐压倒Xen

历史只是偶然，成败听凭运气，没有什么道理好讲的。

我只能根据有限的经验来预言：任何一种号称"大一统方案"的方案最后总是失败。

让我们再大声诵读伟大的Fred Brooks先知的预言：没有银弹，没有银弹，没有银弹~~~
