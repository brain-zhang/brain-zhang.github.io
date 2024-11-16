---
layout: post
title: "how to Calling multiple commands through xargs"
date: 2018-05-01 09:25:03 +0800
comments: true
categories: tools
---

有时候想在xargs后面接多条命令，这个时候直接加`;`是不行的，要这样做:


```
cat a.txt | xargs -I@  sh -c 'command1; command2; ...'

```
