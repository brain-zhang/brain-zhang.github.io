---
layout: post
title: "send large packet by dpdk pktgen"
date: 2015-10-28 17:11:10 +0800
comments: true
categories: network dpdk
---

场景
------
测试qinq 发包，但是tcpreplay是没法带vlan tag的。所以需要用pktgen发送qinq包。

问题
-----
qinq双层vlan tag，有些包大小超过了1518字节，pktgen不支持。

解决方案
--------
修改 dpdk-2.1.0/x86_64-native-linuxapp-gcc/include/rte_ether.h:

    #define ETHER_MAX_LEN 1522

重新编译DPDK，Pktgen，重新加载DPDK驱动

资料
----

* DPDK2.1.0:

http://dpdk.org/browse/dpdk/snapshot/dpdk-2.1.0.tar.gz

* Pktgen2.9.5:

http://dpdk.org/browse/apps/pktgen-dpdk/snapshot/pktgen-dpdk-pktgen-2.9.5.tar.gz


