---
layout: post
title: "alias rm to mv"
date: 2019-01-16 14:00:18 +0800
comments: true
categories: tools
---

之前一直简单的用


``` 
alias rm='mv -f $@ ~/.trash'

``` 

取代rm命令。

这样用着有个不便的地方，就是有时候做个脚本命令，带个`;`的时候会解析有问题。今天突然发现一个用函数来替代的好办法，记一下：


```
alias rm='move1(){ /bin/mv -f $@ ~/.trash/; };move1 $@'

```

参考资料：

https://www.cnblogs.com/f-ck-need-u/p/7385133.html
