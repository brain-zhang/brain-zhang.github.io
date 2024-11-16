---
layout: post
title: "deploy local ntp server on centos7"
date: 2017-06-06 21:20:35 +0800
comments: true
categories: tools
---

有时候需要内网环境搭建一个ntp服务器同步内网的几台机器。

四步走:

## 安装ntpd

    yum -y install ntp ntpdate

## 修改/etc/ntpd.conf

    # line 18: add the network range you allow to receive requests
    restrict 10.0.0.0 mask 255.255.255.0 nomodify notrap

    # local clock
    server 127.127.1.0
    fudge  127.127.1.0 stratum 10

## 重启

    systemctl start ntpd
    systemctl enable ntpd
    firewall-cmd --add-service=ntp --permanent
    firewall-cmd --reload

## 瞄一眼

    watch ntpq -p

注意reach这个值，在启动ntp server服务后，这个值就从0开始不断增加，当增加到17的时候，从0到17是5次的变更，每一次是poll的值的秒数，是64秒*5=320秒的时间。

如果之后从ntp客户端同步ntp server还失败的话，用ntpdate –d来查询详细错误信息，再做判断。
