---
layout: post
title: "What Should You Do If Windows 10 Freezes Randomly"
date: 2019-11-13 11:45:32 +0800
comments: true
categories: tools
---
是的，作为一名码农，日常最主要的工作就是修电脑；

有一台装Win10的Thinkpad T440 笔记本会随机冻结，表现就是所有操作没有反应，鼠标键盘没有响应，画面不动，然后等待1分钟后自我恢复； 每天随机发生>5次；

<!-- more -->

在Google了N多`What Should You Do If Windows 10 Freezes Randomly`的帖子之后，发现有这个问题的人可以组成一个军团，可谓是苦大仇深；

至少这下面所有的方法我都试了一遍：

https://www.partitionwizard.com/partitionmagic/win10-freezes-randomly.html

最后无奈之下挂载winGDB，是的，就是这么无聊，追到了Chrome里面；

我发现，只要关闭Chrome的 "设置->高级->使用硬件加速模式"，问题概率就会大大降低；

这是什么原理，一番探究后，我发现这台笔记本是自动切换核显和独立显卡的；而Intel核显有个选项： "Intel Graphics Control Panel -> Energy management -> Panel Self Refresh"关闭之后就OK了；

好吧，归根到底还是驱动的问题；Intel的这个显卡其实官方没有支持Win10的驱动，这是Win10自己瞎支持的，出现问题再所难免；

以后遇到Win10冻结的情况，你的检查清单上还需要多加两项：

1. Chrome的硬件加速关闭试一试

2. 如果有Intel的核显，关闭`Panel Self Refresh`试一试

>Apparently, disabling Panel Self Refresh (PSR) in the Intel HD Graphics Control Panel application fixed the issue.
>On Lenovo notebook right click on desktop -> Intel Graphics Control Panel -> Energy management -> Panel Self Refresh -> set to Disabled.
>I also set the display to max performance, but I don't think this is relevant.
>Once disabled, I've no more experienced any freeze for several days.

参考：

https://forums.lenovo.com/t5/ThinkPad-X-Series-Laptops/X270-generic-freeze/td-p/3927475/page/5
