---
layout: post
title: "multiline comments in docker file"
date: 2015-04-10 09:07:36 +0800
comments: true
categories: docker tools
---

为了减少Image的fs layout数目，Dockerfile中经常会把多个命令集中到一个 `RUN` 指令下。

多行之后可读性就很差了。

有个比较偏门的写注释的方法:


```
RUN mkdir -p /home/build/npm3 && \
    mkdir -p /home/build/smartprobe && \
    mkdir -p /home/build/bpc3 && \
    `#====================================================` \
    `#=============checkout and install rpms==============` \
    svn export xxx && \
    rpm -ivh --force --nodeps *.rpm && \
    `#====================================================` \
    `#=============checkout and install python==============` \
    ... && \


```

比较实用，推荐之。
