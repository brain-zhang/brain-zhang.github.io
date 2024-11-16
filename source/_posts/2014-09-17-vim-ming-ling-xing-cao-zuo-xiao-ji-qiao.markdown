---
layout: post
title: "Vim 命令行操作小技巧"
date: 2014-09-17 08:30:15 +0800
comments: true
categories: vim tools
---

## vim 使用:进入命令行后，除了直接敲命令外，一般会有两个操作:

1.查看历史指令并执行

2.复制寄存器中的内容
1 查看历史指令需要在进入命令行之前使用q:,再选则就OK了。

2 使用寄存器，一般复制时使用" + [寄存器名称] + y，进入命令行后再输入ctrl R，选择相应的寄存器粘贴就OK了。


## vim tooltips

#### Display CRLF as ^M:


```
:e ++ff=unix

```
