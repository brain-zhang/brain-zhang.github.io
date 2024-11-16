---
layout: post
title: "bitcoind conf template"
date: 2018-11-26 14:51:43 +0800
comments: true
categories: blockchain
---

bitcoin core 0.17版本开始废弃了不少RPC调用，另外RPC配置增加了test.rpcport参数，存一份模板:

<!-- more -->


```
rpcuser=xxxx
rpcpassword=xxxx
rpcallowip=127.0.0.1
rpcport=18332
test.rpcport=8332
rpcthreads=10
server=1
rest=1
walletnotify=/usr/bin/python3 /xxx.py

```

另外`getaddressesbyaccount`即将废弃，可以使用`getaddressesbylabel`代替

`signrawtransaction`即将废弃，实在要用的话只能在启动命令行中加deprecatedrpc指定。


```
bin/bitcoind --conf=/xxx/bitcoin.conf --datadir=/xxx/blockdata/mainnet --deprecatedrpc=signrawtransaction

```
