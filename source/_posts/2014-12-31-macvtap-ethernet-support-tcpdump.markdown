---
layout: post
title: "Macvtap Ethernet support tcpdump"
date: 2014-12-31 17:05:01 +0800
comments: true
categories: macvtap network
---

用macvtap模拟网卡时，用tcpdump抓包是抓不到的，后来发现3.14版本以上的内核修正了这一点。

参考这个提交:

https://github.com/torvalds/linux/commit/6acf54f1cf0a6747bac9fea26f34cfc5a9029523
