---
layout: post
title: "the history of X86"
date: 2018-09-12 10:22:01 +0800
comments: true
categories: develop
---

我们平时老看到`X86指令集`, `X86架构`等等词汇，很容易就猜到这个86来源于Intel那款名动天下的处理器--8086，那么8086的名字又是怎么来的呢？

<!-- more -->

这是一个遥远的传说，各种解释众说纷纭，挑两个有说服力的段子吧:

#### 说法1

当intel发明第一颗4位的位处理器的时候，intel把他叫4004。在当时，intel也没有意识到这就是微处理器，（微处理器是后来人的说法），intel当时只是给做手持计算器的厂家来定制处理器。

因为4004的指令集很有限，所以又搞出来了一个升级版本4040。

8008是4004的8位版，8080是4040的8位版。

8085是8080的单5伏电压版。

8085升级到16位后，就叫8086了。

嗯，还是很有逻辑的。

#### 说法2

微处理器是在70年代末发明的。 接近80年，所以，前两个数字就是这么来的;

当时微处理器是8位的，因此，第3个数字是8;

在8085和8086 cpu之前，8080处理器是需要+5-5和12v电压来工作。 随着技术的进步，只需要单一的5v供电了，因此，最后一个数字是5;

8085升级到16位后，就叫8086了;

好吧，也说得通。


#### 不管怎么说，反正Intel推出的8086在历史上的经典地位不容置疑；那我们来简单回顾一下Intel CPU发展的历史吧

* 20世纪70年代末，Intel生产了著名的16位8086处理器，之后又推出了80186与80286；

* 1985年，Intel继摩托罗拉之后，第二个研制出32位的微处理器80386；

* 8086、80286、80386等等，这一系列CPU就称作x86，正式一点称作IA-32（Intel Architecture 32-bit）。正是这个架构开启了Intel在个人PC CPU领域的无敌之路，后来的操作系统、编译器、应用软件无一不是把`适配X86指令`作为核心竞争力；

* 1989年，Intel推出80486处理器，具有浮点运算功能； 

* 因为当初与Intel竞争微处理器的摩托罗拉公司是以86开头的，如68000，68010，68020，而且AMD也崭露头角，他们也搞出来AM386，AM486等等，令Intel不胜其烦；而当时的法律不允许将数字注册为商标，于是1993年，Intel推出奔腾(Pentium)处理器，不再以数字命名其产品；Pentium刚刚推出的时候，命名及其混乱，有人叫I586，有人叫P5，有人叫PI，还有人叫奔腾的芯，更别提什么梦幻神器，裸奔天下等等搞笑名词了~~不管怎么说，那时候伴随我们记忆的不只是Pentium这个名字，还有那个经典的"等等等你等"的广告音乐，Intel又凭借Pentium这个架构继续无敌并寂寞着

* 在Pentium时代，其实AMD也不是毫无作为，老一代DIY玩家们一定还对Athlon K7的传说记忆犹新，尤其是当时那些拉风的译名，什么"速龙"、"毒龙"、"钻龙"等等，我得说，这个时期的农企实在是很时髦，远远不像他们后来的市场部那么傻13

* 当然，当时最璀璨的舞者，我只献给活在DIYer心里那个最美好的名字--图拉丁赛扬；正是这款CPU成为了许多人的电脑时代的启蒙者

* 2001年开始，Intel将用于服务器以及工作站的Pentium 4 Xeon独立成全新的品牌“Xeon”（至强）)；正如这个名字所蕴含的霸气一样，这个品牌延续到了今天

* 2006年，Intel发布“Core”（酷睿）品牌，用作英特尔的旗舰级处理器系列的新品品牌； 然后，这个品牌经历了数代架构更迭，一直伴随我们到了今天

* 同样的，围绕指令集从32位跃迁到64位的过程中，AMD和Interl在这段时间还爆发了一场惊天缠斗；Intel作为CPU市场的领跑者，觉得自己理应主导32位到64位时代跃进的浪潮；早在Pentium时代，他们就制定了Intel 64计划；然而，由于一个大公司内部的种种政治斗争，市场斗争，人的本性里面悲剧的傲慢，这个过程种出现了种种败着昏棋，最终AMD64架构在IA-32上新增了64位寄存器，并兼容早期的16位和32位软件，可使现有以x86为对象的编译器容易转为AMD64版本，在2003年9月推出了AMD64；在64位时代由追随者变成领跑者

* Intel此时如梦方醒，慌忙将AMD的指令集拿过来稍作加工推出自己的兼容产品；然后就是两个公司营销和市场人员、法律人员旷日持久的撕逼大战；中间诞生了许许多多匪夷所思的营销名词，比如A64, I64, IA32E，iAMD64，Intel64，X86-64等等等等；如果你是一个Linux爱好者，很容易看到各个软件包都会注明Amd64, X86_64等等，这是那场混乱大战的遗留物

#### 总结一下现在的主流

* 32/64 位系统编译在32位系统上运行 => x86

* 32 系统上编译64位系统上运行 => x86_amd64

* 64 系统上编译在64位系统上运行 => amd64

#### 看看MSDN的解释:

> The following list describes the various versions of cl.exe (the Visual C++ compiler):
> 
> x86 on x86
> Allows you to create output files for x86 machines. This version of cl.exe runs as a 32-bit process, native on an x86 machine and under WOW64 on a 64-bit Widows operating system. 
> Itanium on x86 (Itanium cross-compiler) 
> Allows you to create output files for Itanium. This version of cl.exe runs as a 32-bit process, native on an x86 machine and under WOW64 on a 64-bit Widows operating system.
> 
> x64 on x86 (x64 cross-compiler)
> Allows you to create output files for x64. This version of cl.exe runs as a 32-bit process, native on an x86 machine and under WOW64 on a 64-bit Widows operating system.
> 
> Itanium on Itanium
> Allows you to create output files for Itanium. This version of cl.exe runs as a native process on an Itanium machine.
> 
> x64 on x64
> Allows you to create output files for x64. This version of cl.exe runs as a native process on an x64 machine.

#### 总之CPU的历史生动说明了了计算机界的很多老梗是如何诞生的，比如很多人都疑惑为什么Windows的发布名称是Win95->W98->W98SE->Win2000(NT)->WinXP->Vista->Win7->Win10，等等等等；这种现象是商业环境、市场营销、法律风险以及随意拍脑门的高管，放荡不羁的开发团队合力促成的~~~
