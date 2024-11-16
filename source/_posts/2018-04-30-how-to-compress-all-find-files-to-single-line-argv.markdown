---
layout: post
title: "how to compress all find files to single line argv"
date: 2018-04-30 10:39:39 +0800
comments: true
categories: tools
---

有时候find的所有文件要合并为一个argv管道到一个命令里面:


```
find /path/to/directory/ -name *.csv -print0 | xargs -0 -I file cat file > merged.file

```
