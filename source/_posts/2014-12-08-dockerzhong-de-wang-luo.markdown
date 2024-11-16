---
layout: post
title: "docker中的网络"
date: 2014-12-08 08:25:53 +0800
comments: true
categories: docker network
---

Docker的默认网络是非常弱的，他使用的是一个虚拟网桥和container中的veth pair通信，在container中，默认是没有对外的IP的，外部主机或容器只能通过NAT，或者自定义iptable来实现主机或容器间的互联互通。
这种局限性非常明显:

* 如果我要配置一个sshd service，需要手工配置转发规则，非常不便

* 无法使用DHCP

* NAT无法在宿主机上用一个端口提供不同服务，所以有多个container绑定到一个物理网卡时，因为无法分配多个对外IP，所以诸如Http 这样的服务只能跑在同一IP的不同端口上。

* 在Container中无法正常tcpdump


理想的容器内网卡应该像VMware的NSX那样，让你'基本上'感觉不到这是个虚拟的网卡，当然，这个和Docker的初衷有点不符了。但我们解决问题为先，工具是那一个，但不同人用法不同。

将Docker Container连接到本地网络，有四种搞法 (具体请参考:http://blog.oddbit.com/2014/08/11/four-ways-to-connect-a-docker/)，下面简单描述下:

* 采用官方默认的搞法，用NAT:


```
ip addr add 10.12.0.117/21 dev em1

docker run -d --name web -p 10.12.0.117:80:80 centos/simpleweb

```

   这种方法简单，但也有上面所说的各种缺点

* 建立自己的网桥和veth pair，为每个网桥分配一个IP，每个veth对绑定一个网桥，映射进docker容器，这样在容器内就得到了一个接近于真实的网卡。并且有能与本地网络的通信

    这种办法其实是对默认docker网络实现的一种升级，但是解决了原来的诸多局限，缺点是操作比较麻烦，另外容器内用tcpdump也会有问题

* 使用Open vSwitch Bridge，模拟第二种办法。

    这种方法就是用Open vSwitch简化了操作，但是又引入了一套东西。

* 建立macvlan虚拟网卡，容器启动后用nsenter工具映射到容器的network namespace中

    这种办法我觉得是最干净简洁的，而且采用macvlan，还意外获得了一种能力，就是你能在宿主机上创建子macvlan设备，从而能向容器内的macvlan设备打入精确的流量。
    采用这种方法得到的container，可以在里面启动sshd，远程ssh上去各种操作，这样使用同一般的虚拟机没有多大差别。
    另外，在容器内tcpdump包也很完美，如果想捕获二层协议包，可以用macvtap替换macvlan。

需要注意的是，如果想要tcpdump macvtap，需要linux kernel 3.14以上的支持，参见[这里](https://github.com/torvalds/linux/commit/6acf54f1cf0a6747bac9fea26f34cfc5a9029523)。


最后推荐为了简化macvlan的操作，我写的一个小工具:[dockerfly](https://github.com/brain-zhang/dockerfly)


参考:

* Linux 上的基础网络设备详解

http://www.ibm.com/developerworks/cn/linux/1310_xiawc_networkdevice/index.html

* Linux 上虚拟网络与真实网络的映射

http://www.ibm.com/developerworks/cn/linux/1312_xiawc_linuxvirtnet/index.html

* 网络虚拟化技术: TUN/TAP MACVLAN MACVTAP

https://blog.kghost.info/2013/03/27/linux-network-tun/

* Coupling Docker and Open vSwitch

http://fbevmware.blogspot.com/2013/12/coupling-docker-and-open-vswitch.html

* four ways to connect a docker

http://blog.oddbit.com/2014/08/11/four-ways-to-connect-a-docker/

* Docker containers should not run an SSH server

https://news.ycombinator.com/item?id=7950326

* Proposal: Native Docker Multi-Host Networking

https://github.com/docker/docker/issues/8951
