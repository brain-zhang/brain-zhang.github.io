---
layout: post
title: "为centos添加EPEL Repo"
date: 2014-03-13 20:04:58 -0700
comments: true
categories:centos epel repo yum
---

centos默认的源软件不是很全，大部分时候需要添加EPEL源。

## centos5.x

    wget http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
    wget http://rpms.famillecollet.com/enterprise/remi-release-5.rpm
    sudo rpm -Uvh remi-release-5*.rpm epel-release-5*.rpm

## centos6.x

    wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
    sudo rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm

## 添加完毕后可以到/etc/yum.repos.d里面看一下

    $ ls -1 /etc/yum.repos.d/epel* /etc/yum.repos.d/remi.repo
    /etc/yum.repos.d/epel.repo
    /etc/yum.repos.d/epel-testing.repo
    /etc/yum.repos.d/remi.repo

## 设置remi repository

remi repository更新很快，如果你很需要htopxxx最新版本这样的话最好打开

    sudo vim /etc/yum.repos.d/remi.repo

编辑 [remi]段:

    name=Les RPM de remi pour Enterprise Linux $releasever - $basearch
    #baseurl=http://rpms.famillecollet.com/enterprise/$releasever/remi/$basearch/
    mirrorlist=http://rpms.famillecollet.com/enterprise/$releasever/remi/mirror
    enabled=1
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
    failovermethod=priority

## 解决仓库安装失败的问题

有时候某个软件可以Search，但安装一直报错:

    http://download.fedoraproject.org/pu...ry.sqlite.bz2: [Errno 12] Timeout: <urlopen error timed out>
    Trying other mirror.

最简单的修复办法就是重建repos

    yum clean all
    rpm --rebuilddb
    yum update

90%的情况会奏效
