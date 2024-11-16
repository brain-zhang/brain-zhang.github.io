---
layout: post
title: "Linux多网卡多路由设置"
date: 2014-12-30 09:40:53 +0800
comments: true
categories: tools network
---

折腾了半天，原始出处不知道了，转记一下。

比如如果一个linux服务器有三个口接三个不同的网络，假设对应的网络信息是如此

* eth0是电信，ip地址为1.1.1.1/24，电信网关为1.1.1.254

* eth1是网通，ip地址为2.2.2.2/24，网通网关为2.2.2.254

* eth2是教育网，ip地址为3.3.3.3/24，教育网网关为3.3.3.254


传统情况下，如果是为了从内向外访问获得更好的速度，让访问电信走电信，访问网通走网通，那么配置是网关只能够配置一个。

比如以电信为主的，那么网关就只设置电信的1.1.1.254，而针对网通和教育网设置不同的路由，路由下一跳指向网通和教育网对应的 网关。

如果这样做的目的只是实现内部访问外面，那么是没问题了，但是如果是为了让外面的用户能够正常访问到服务器上的服务就会出问题。比如电信用户会无法访问网通和教育网的ip，网通用户会无法访问电信和教育网的ip。

要解决这个问题，思路就是由哪个网口进来的流量希望全部就由哪个回去。用lartc里面提到的方法就是来源的口不同，走不同的路由表。在默认的路由表基础上再建立三个路由表。

用 ip route show 可以看到默认有local,main,default三个路由表，这三个路由表的名称命名来自 /etc/iproute2/rt_tables ，这里先在这个配置文件里面添加三个不同的路由表表名，


```
echo “101 ChinaNet” >> /etc/iproute2/rt_tables
echo ”102 ChinaCnc“ >> /etc/iproute2/rt_tables
echo ”103 ChinaEdu“ >> /etc/iproute2/rt_tables

```

之后建立这三个路由表的内容，因为这三个路由表的只是用来响应来自不同接口的，而不是用来相应从哪个接口出去的，所以只需要每个路由表里面建立默认网关即可。


```
ip route add default via 1.1.1.254 dev eth0 table ChinaNet
ip route add default via 2.2.2.254 dev eth1 table ChinaCnc
ip route add default via 3.3.3.254 dev eth2 table ChinaEdu

```

之后再加上三条规则，使来自不同的口的走不同的路由表


```
ip rule add from 1.1.1.1 table ChinaNet
ip rule add from 2.2.2.2 table ChinaCnc
ip rule add from 3.3.3.3 table ChinaEdu

```

至此无论是电信还是网通还是教育网用户，访问三个ip的任意一个地址都能够连通了。即便是服务器上本身的默认路由都没有设置，也能够让外面的用户正常访问。

命令汇总：


```
ip route show

echo “101 ChinaNet” >> /etc/iproute2/rt_tables
echo ”102 ChinaCnc“ >> /etc/iproute2/rt_tables
echo ”103 ChinaEdu“ >> /etc/iproute2/rt_tables // 这里也可以直接通过Vi编辑

ip route add default via 1.1.1.254 dev eth0 table ChinaNet
ip route add default via 2.2.2.254 dev eth1 table ChinaCnc
ip route add default via 3.3.3.254 dev eth2 table ChinaEdu

ip rule add from 1.1.1.1 table ChinaNet
ip rule add from 2.2.2.2 table ChinaCnc
ip rule add from 3.3.3.3 table ChinaEdu //如果用数字，可以不要上面的“echo”过程

```

