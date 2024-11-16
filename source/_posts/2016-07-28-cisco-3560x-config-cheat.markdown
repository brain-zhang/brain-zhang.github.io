---
layout: post
title: "Cisco 3560X config cheat"
date: 2016-07-28 10:02:06 +0800
comments: true
categories: cisco tools
---
工作需要，学习了Cisco的路由器配置，记一下:

* 查看所有信息


```
    show run

```

* 查看span


```
    show span

```

* 为某个vlan id建立spanning-tree


```
    spanning-tree vlan 15

```

* 取消某个vlan id的spanning-tree


```
    no spanning-tree vlan 15

```

* 将某个端口加入vlan中


```
    sh run init gi 0/39
    config t
    switchport access vlan 14

```

* 保存配置


```
    do wr
    copy running-config startup-config

```


顺便记一下cisco catalyst交换机配置

* 登陆交换机


```
    ssh admin@10.1.0.2

```

* 查看现有配置


```
    show running-config

```

* 批量修改vlan：端口37-39改成vlan15。端口41-46改成trunk


```
    #conf t
    (config)#int ra g0/37 -39
    (config-if-range)#sw mo acc
    (config-if-range)#sw acc vl 15
    (config-if-range)#exit
    (config)#int ra g0/41 -46
    (config-if-range)#sw tr e d
    (config-if-range)#sw mo tr
    (config-if-range)#end
    #wr

```

* 开启/关闭端口


```
    TEST3#conf t
    Enter configuration commands, one per line.  End with CNTL/Z.
    TEST3(config)#int g0/41
    TEST3(config-if)#sh
    TEST3(config-if)#shutdown
    TEST3(config-if)#no shutdown
    TEST3(config-if)#end
    TEST3#

```

例如 配置vlan15 和 trunk:


```
interface GigabitEthernet0/39
 switchport access vlan 15
  switchport mode access

interface GigabitEthernet0/46
 switchport trunk encapsulation dot1q
  switchport mode trunk


```

去掉


```
no switchport access vlan 15

```
