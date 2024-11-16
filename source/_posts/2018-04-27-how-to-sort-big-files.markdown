---
layout: post
title: "How to sort big files"
date: 2018-04-27 17:03:22 +0800
comments: true
categories: tools
---

在linux要排序一个100G的文件，压力比较大

并行解决之:


```
    sort -S 50% --parallel=2 -uo list-sorted.txt list.txt

```

注意这一招在管道里面行不通，所以要用管道的话一定要先重定向到一个文件里面中转一下。
