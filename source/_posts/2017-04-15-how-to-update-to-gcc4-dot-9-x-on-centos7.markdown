---
layout: post
title: "how to update to gcc4.9.x on centos7"
date: 2017-04-15 15:50:53 +0800
comments: true
categories: tools gcc centos
---

现在很多软件包默认编译要求GLIBCXX >=3.4.20，碰到这种事redhat系又哭了，目前Centos7.x默认仓库里的gcc还是4.8.5的，所以需要一个办法升级gcc相关组件>=4.9.1。

CentOS下升级gcc版本有两个途径，一个是添加其他源进行自动升级，一个是手动编译升级，这里先顺便讲下自动升级的两个办法：

### 添加Fedora源

在 /etc/yum.repos.d 目录中添加文件 FedoraRepo.repo ，并输入以下内容:

    [warning:fedora]
    name=fedora
    mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-23&arch=$basearch
    enabled=1
    gpgcheck=1
    gpgkey=https://getfedora.org/static/34EC9CBA.txt

然后执行

    yum update gcc gcc-c++

### 使用Devtoolset-4升级

    yum install centos-release-scl
    yum install devtoolset-4-gcc*
    scl enable devtoolset-4 bash
    which gcc
    gcc --version

