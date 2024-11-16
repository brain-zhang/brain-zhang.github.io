---
layout: post
title: "tcpdump commands"
date: 2015-05-08 12:06:22 +0000
comments: true
categories: tcpdump
---

tcpdump 的抓包保存到文件的命令参数是-w xxx.cap

* 抓eth1的包

```
tcpdump -i eth1 -w /tmp/xxx.pcap

```

* 抓eth1的包，用ip+port的形式显示通信对

```
tcpdump -i eth1 -nn -w /tmp/xxx.pcap

```

* 抓 192.168.1.123的包

```
tcpdump -i eth1 host 192.168.1.123 -w /tmp/xxx.cap

```

* 抓192.168.1.123的80端口的包

```
tcpdump -i eth1 host 192.168.1.123 and port 80 -w /tmp/xxx.cap

```

* 抓192.168.1.123的icmp的包

```
tcpdump -i eth1 host 192.168.1.123 and icmp -w /tmp/xxx.cap

```

* 抓192.168.1.123的80端口和110和25以外的其他端口的包

```
tcpdump -i eth1 host 192.168.1.123 and ! port 80 and ! port 25 and ! port 110 -w /tmp/xxx.cap

```

* 抓vlan 1的包

```
tcpdump -i eth1 port 80 and vlan 1 -w /tmp/xxx.cap

```

* 抓pppoe的密码

```
tcpdump -i eth1 pppoes -w /tmp/xxx.cap

```

* 以100m大小分割保存文件， 超过100m另开一个文件

```
tcpdump -i eth1 -w /tmp/xxx.cap  -C 100m

```

* 把后两个数据包并到一个数据包merge.pcap

```
mergecap -w merge.pcap 1.pcap 2.pcap

```

* 按照radius条件过滤数据包

```
tshark -r 1.pcap radius -w radius.pcap

```

* 按照数据包数分割一个大的数据

```
editcap -c 1000000 merge.pcap split01.pcap

```

* split pcap

```
editcap -c 100000 in.pcap out.pcap

```
