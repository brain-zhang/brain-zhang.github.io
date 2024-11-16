---
layout: post
title: "lnd low rescan speed for startup"
date: 2021-06-05 17:31:07 +0800
comments: true
categories: blockchain lightning
---

Lnd启动的时候需要扫描最近数百个区块来验证安全性，做rescan动作的时候慢的出奇，有时候需要30分钟才能完成这个动作：

https://github.com/lightningnetwork/lnd/issues/760

如果单独启动Lnd可以耐着性子等，但是如果用Lit(lightning-network-termial) 启动的话，因为它集成了数个服务，所以在等Lnd RPC服务就绪前，往往等不到扫描完毕就超时退出了...

因为Lit Debug Log没有打全，我对于这个问题百思不得其解，其在bitcoin Regnet, Testnet, Mainnet上面的表现各不相同....

最后找到的一劳永逸的解决办法有两个：

1. 换btcd，不要用bitcoin core了

2. 换ssd硬盘，花钱解决


话说，bitcoin core还好一点，Ethereum一个全节点的成本已经越来越高了，硬盘需求已经直奔2T SSD了；对于个人来说，在AWS上启动一个2T云硬盘的vps着实花费不小；


