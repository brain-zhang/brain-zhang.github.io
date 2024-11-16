---
layout: post
title: "migrate firewalld to iptables on centos7"
date: 2017-12-06 16:23:22 +0800
comments: true
categories: tools iptables linux
---

## 关闭 FireWall

    systemctl stop firewalld.service #停止firewall
    systemctl disable firewalld.service #禁止firewall开机启动

## 安装 iptables

    yum install iptables-services

<!-- more -->

## 配置 iptables

    #!/bin/bash

    IF="eth0"

    #清除规则
    /sbin/iptables -F
    /sbin/iptables -X
    /sbin/iptables -Z

    # 预定义策略
    /sbin/iptables -A INPUT -s 127.0.0.1 -j ACCEPT  # 允许回环接口可以被访问
    /sbin/iptables -P INPUT   DROP # 默认是拒绝访问
    /sbin/iptables -P OUTPUT  ACCEPT  # 允许本机访问其他机器，无限制
    /sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    /sbin/iptables -A INPUT -p icmp -j ACCEPT # 允许ping


    #允许的本机服务
    /sbin/iptables -A INPUT -p TCP -i $IF --dport 22 -j ACCEPT        # SSH
    # /sbin/iptables -A INPUT -p TCP -i $IF --dport  3306 -j ACCEPT        # mysql
    /sbin/iptables -A INPUT -p TCP -i $IF --dport  80 -j ACCEPT        # web
    /sbin/iptables -A INPUT -p TCP -i $IF --dport  8888 -j ACCEPT        # web

    # 黑名单
    #/sbin/iptables -A INPUT -s 1.1.1.0/24 -j DROP
    #/sbin/iptables -A INPUT -s 1.1.1.0 -j DROP

    # 信任的网络和IP
    /sbin/iptables -A INPUT -s 1.1.1.1/24 -j ACCEPT # 信任的网络

    # 保存配置
    /usr/libexec/iptables/iptables.init save
