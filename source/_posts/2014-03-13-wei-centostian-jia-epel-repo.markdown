---
layout: post
title: "为centos添加EPEL Repo"
date: 2014-03-13 20:04:58 -0700
comments: true
categories: centos epel tools
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

## 开发工具套装

    yum groupinstall "Development Tools"

## SCL源

http://wiki.centos.org/AdditionalResources/Repositories/SCL

## 解决仓库安装失败的问题

有时候某个软件可以Search，但安装一直报错:

    http://download.fedoraproject.org/pu...ry.sqlite.bz2: [Errno 12] Timeout: <urlopen error timed out>
    Trying other mirror.

最简单的修复办法就是重建repos

    yum clean all
    rpm --rebuilddb
    yum update

90%的情况会奏效

## yum只下载安装包

    [RHEL5]
    yum -y install yum-downloadonly
    yum install mongodb-org --downloadonly

    [RHEL6]
    yum install yum-plugin-downloadonly
    yum install --downloadonly --downloaddir=. mongodb-org

## yum提取已经安装的rpm包

    yum install yum-utils
    yumdownloader <package>
    yumdownloader <package> --resolve

## yum升级kernel

http://elrepo.org/tiki/kernel-ml

##  elrepo url

http://elrepo.org/tiki/tiki-index.php

http://elrepo.org/linux/kernel/

http://mirrors.sohu.com/centos/6.6/xen4/x86_64/Packages/

## mongodb RPM repo

https://repo.mongodb.org/yum/redhat

## 163镜像源

http://mirrors.163.com/.help/centos.html


## rpm 常用命令

* 重装某个包


```
rpm -ivh --replacepkgs xxx.rpm

```

* 修改prefix


```
rpm -qp --queryformat "%{defaultprefix}\n" <packagefile>
rpm -ivh --prefix <packagefile>

```

* 查询某个包包含的文件


```
rpm -ql <packagefile>
rpm -qs <packagefile>

```

* 查询某个包包含的配置文件


```
rpm -qc <packagefile>

```

* 查询某个包安装时要执行的脚本文件


```
rpm -q --scripts <packagefile>

```


* 查询某个文件属于哪个包


```
rpm -qf <filepath>

```

* 查询某个可执行文件的配置文件和log文件


```
rpm -qcf <filepath>

```

* 寻找最近安装的包

```
find /bin -type f -mtime -14 | rpm -qF
rpm -qa --queryformat '%{installtime} %{name}-%{version}-%{release} %{installtime:date}\n' | sort -nr +1 | sed -e 's/^[^ ]* //'

```

* 寻找最大的安装包

```
rpm -qa --queryformat '%{name-%{version}-%{release} %{size}\n' | sort -nr +1}'

```

* 解压一个rpm文件

```
rpm2cpio xxx.rpm | cpio -div

```
