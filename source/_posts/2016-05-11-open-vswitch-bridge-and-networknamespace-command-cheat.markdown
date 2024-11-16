---
layout: post
title: "Open vSwitch bridge and NetworkNameSpace command cheat"
date: 2016-05-11 15:41:02 +0800
comments: true
categories: openvswitch network
---

* 启动

        service openvswitch start

* 创建网桥

        ovs-vsctl add-br br0
        ifconfig br0 up

* 显示所有网桥

        ovs-vsctl show

* 删除网桥

        ovs-vsctl del-br br0

* 增加端口

        ovs-vsctl add-port br0 eth0

* 设置网卡为none

        dhclient br0

* 用 Namespace 模拟两台虚拟机网络

        p netns add network1
        ip netns add network2

* 创建两个虚拟网卡并加入网桥

        ovs-vsctl add-port br0 vport1 -- set interface vport1 type=internal
        ovs-vsctl add-port br0 vport2 -- set interface vport2 type=internal
        tunctl -p -t vport1
        tunctl -p -t vport2

* 两个虚拟网卡接入namespace

        ip link set vport1 netns network1
        ip link set vport2 netns network2

* 设置虚拟网卡的IP

        ip netns exec network1 ifconfig vport1 192.168.0.1/24 up
        ip netns exec network2 ifconfig vport2 192.168.0.2/24 up

* 两个namsespace PING

        ip netns exec network1 ping 192.168.0.2
        ip netns exec network2 tcpdump -i vport2

* 两个namsespace  NC传输

        ip netns exec network2 nc -l 1234
        ip netns exec network2 tcpdump -i vport2
        ip netns exec network1 nc 192.168.0.2 1234

* 显示vlan信息

        ovs-appctl fdb/show br0

* 显示openflow信息

        ovs-ofctl show br0

* 显示流表信息

        ovs-ofctl dump-flows br0

* 显示网桥详细信息

        ovs-vsctl list Bridge

* 显示端口详细信息

        ovs-vsctl list Port

* 显示接口详细信息

        ovs-vsctl list Interface
