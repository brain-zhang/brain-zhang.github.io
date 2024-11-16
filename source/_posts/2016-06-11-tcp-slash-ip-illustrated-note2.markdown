---
layout: post
title: "TCP/IP Illustrated Note2"
date: 2016-06-11 22:26:09 +0800
comments: true
categories: TCP/IP
---

## traceroute

#### 原理

开始时发送一个TTL字段为1的UDP数据报，然后将TTL字段每次加一，以确定路径中的每个路由器。每个路由器在丢弃UDP数据报时都返回一个ICMP超时报文2，而最终目的的主机则产生一个ICMP端口不可达的报文。

#### IP源站选路选项

* 严格的源路由选择

发送端指明IP数据包所必须采用的确切路由。如果一个路由器发现源路由所指定的下一个路由不在其直接连接的网络上，那么它会返回一个“源站路由失败”的ICMP差错报文。

* 宽松的源站选路

发送端指明了一个数据报经过的IP地址清单，但是数据报在清单上指明的任意两个地址之间可以通过其它路由器。

## IP选路

一个简单的路由表

    Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
    default         192.168.159.2   0.0.0.0         UG    0      0        0 eth0
    192.168.159.0   *               255.255.255.0   U     0      0        0 eth0
    192.168.159.0   *               255.255.255.0   U     0      0        0 eth1

注意Flags一列，它有5种不同的标志:

* U (route is up) 路由启用
* H (target is a host) 目标是主机
* G (use gateway) 使用网关
* R (reinstate route for dynamic routing)
* D (dynamically installed by daemon or redirect)
* M (modified from routing daemon or redirect)

主机表项比网络表项具有更高的优先级，而网络表项比默认项具有更高的优先级。

## UDP

UDP长度字段指的是UDP首部和UDP数据的总长度

UDP校验和覆盖UDP首部和数据，而IP首部校验和只覆盖IP首部

永远不要完全相信数据链路的CRC校验，应该始终打开端到端的校验和功能。另外，即使是打开了，也要小心，UDP和TCP的校验和也不是可以百分百信赖的。

注意两个ICMP报文和UDP的交互：ICMP不可达报文和ICMP源站抑制差错报文


