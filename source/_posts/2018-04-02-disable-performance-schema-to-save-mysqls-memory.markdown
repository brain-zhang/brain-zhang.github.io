---
layout: post
title: "disable performance_schema to save mysql's memory"
date: 2018-04-02 09:14:01 +0800
comments: true
categories: tools
---
小VPS内存一般都不大，比如 1GB 什么的。估计总是发现装完 LAMP 就基本上内存全用光了。

访问量不大的话，可以在 my.conf 中加入以下配置，关掉性能优化。


```
[mysqld]
performance_schema=off

```
