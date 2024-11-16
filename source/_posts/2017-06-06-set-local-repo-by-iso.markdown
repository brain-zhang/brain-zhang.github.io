---
layout: post
title: "set local repo by iso"
date: 2017-06-06 22:15:22 +0800
comments: true
categories: tools
---

想要挂载一个iso安装镜像作为本地repo

## mount iso

    mkdir -p /mnt/cdrom
    mount -t iso9660 -o loop /home/Centosxxxx.iso /mnt/cdrom

## set local repo

    vi /etc/yum.repos.d/local.repo

    [localrepo]
    name=Unixmen Repository
    baseurl=file:///mnt/cdrom
    gpgcheck=0
    enabled=1

## set up

    yum clean all
    yum repolist
