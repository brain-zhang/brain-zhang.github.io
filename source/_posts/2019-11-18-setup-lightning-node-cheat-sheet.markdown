---
layout: post
title: "Setup Lightning Node Cheat Sheet"
date: 2019-11-18 15:14:19 +0800
comments: true
categories: blockchain lightning
---

运营一个闪电节点的基本命令速查；

<!-- more -->

## Bitcoin Core

#### 启动

```
bitcoind --conf=/opt/bitcoin/blockdata/bitcoin.conf --datadir=/opt/bitcoin/blockdata/
```

如果需要一些老接口

```
bitcoind --conf=/opt/bitcoin/blockdata/bitcoin.conf --datadir=/opt/bitcoin/blockdata/ --deprecatedrpc=signrawtransaction
```

#### bitcoin.conf

```
rpcuser=user
rpcpassword=password
#rpcallowip=127.0.0.1/16
rpcallowip=0.0.0.0/0
rpcport=8332
test.rpcport=8332
rpcthreads=10
server=1
rest=1
testnet=0
zmqpubrawblock=tcp://127.0.0.1:28332
zmqpubrawtx=tcp://127.0.0.1:28333

#walletnotify=/usr/bin/echo "hello"
```


## Lnd

接口丰富，自带rpc和restapi接口，迭代速度快；

https://github.com/lightningnetwork/lnd

#### 部署

```
lnd --bitcoin.active --bitcoin.testnet --debuglevel=debug --bitcoin.node=bitcoind --bitcoind.rpcuser=user --bitcoind.rpcpass='password' --bitcoind.zmqpubrawblock=tcp://127.0.0.1:28332 --bitcoind.zmqpubrawtx=tcp://127.0.0.1:28333 --listen=0.0.0.0:9736 --externalip=207.246.105.100 --no-macaroons 2>&1 >> lndtest.log
```

#### 常用命令

* 解锁钱包

```
lncli  --network=testnet unlock
lncli  --network=testnet newaddr
```

* 查看余额

```
lncli  --network=testnet walletbalance
lncli  --network=testnet listunspent
```

* 连接到一个闪电节点

```
lncli  --network=testnet connect "027455aef8453d92f4706b560b61527cc217ddf14da41770e8ed6607190a1851b8@3.13.29.161:9735"
```

* 打开一个通道

```
lncli  --network=testnet openchannel --node_key 027455aef8453d92f4706b560b61527cc217ddf14da41770e8ed6607190a1851b8 100000
```

* 支付

```
lncli  --network=testnet sendpayment --pay_req "lntb10n1pw6gf60pp5jxwg30u3k7qw2lzef7cnpy6tmnd80q2v5ytglf5tdaalrejhprzsdqhvf6xxmt9ypkxuepqw3jhxaqcqzpg9jsccqelkelayq89ydgrhxwf0hv2ffkdu2y6l27vtpmscszxj3pjsh..."
```

* 接收付款

```
lncli  --network=testnet addinvoice --memo "invoice for lnd.fun test3" --amt 100000
```

* 关闭通道

```
lncli  --network=testnet closechannel "1243f60a54c4c6b8ab5d124a0c701792e085ab13a68da135ca3ffbabb461f1cc"
```

* 链上发送全部余额

```
lncli  --network=testnet sendcoins tbxxxxxx  --sweepall
```

## C-lightning

接口简洁，能直接集成lightning-charge；

https://github.com/ElementsProject/lightning

#### 部署

* c-lightning提供了systemctl 服务脚本:

```
cat /etc/systemd/system/lightning.service


[Unit]
Description=c-Lightning daemon

[Service]
ExecStart=/usr/bin/lightningd --pid-file=/root/.lightning/lightning.pid --daemon
PIDFile=/root/.lightning/lightning.pid
User=root
Type=forking
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

* 配置文件:

```
~/.lightning/config

alias=brain_zhang_lightning_testnode
log-level=debug
#network=bitcoin
network=testnet
bitcoin-rpcuser=user
bitcoin-rpcpassword=password
bitcoin-rpcconnect=127.0.0.1
bitcoin-rpcport=18332
log-file=/var/log/lightning.log
bind-addr=
announce-addr=x.x.x.x:9735
```

* 注册、启动服务

```
systemctl enable lightning
systemctl start lightning
```

#### 常用命令

* 建立一个新地址

```
lightning-cli newaddr
```

* 查看线上钱包地址

```
lightning-cli dev-listaddrs
```

* 连接node (1ml.com node)

```
lightning-cli connect 02312627fdf07fbdd7e5ddb136611bdde9b00d26821d14d94891395452f67af248@23.237.77.12:9735
```

* 建立通道

```
lightning-cli fundchannel id satoshi [feerate] [announce] [minconf]
```

* 查看链上和链下余额

```
lightning-cli listfunds
```

* 支付

Send payment specified by {bolt11} with {amount}

```
lightning-cli pay bolt11 [msatoshi] [label] [riskfactor] [maxfeepercent] [retry_for] [maxdelay] [exemptfee]
```
   

* 收款

Create an invoice for {msatoshi} with {label} and {description} with optional {expiry} seconds (default 1 hour), optional {fallbacks} address list(default empty list) and optional {preimage}

```
lightning-cli invoice msatoshi label description [expiry] [fallbacks] [preimage] [exposeprivatechannels]
```
    

## C-lightning && lightning-charge

https://github.com/btcme/lightning-charge

#### 部署

lightning-charge最好用docker直接集成c-lightning一把启动，比如我已经运行了一个bitcoin core全节点，可以直接下面的命令启动:

```
docker run -d -u `id -u` -v `pwd`/data:/data -p 9735:9735 -p 9112:9112 \
             -e API_TOKEN=mySecretToken \
             -e NETWORK=testnet  \
             -e BITCOIND_URI="http://user:password@172.18.0.1:18332" \
             shesek/lightning-charge
```
注意BITCOIND_URL的IP是docker容器内向外连接的，如果不是用net的方式启动，要填docker的网桥地址；

* 查询运行状况

```
curl http://api-token:mySecretToken@localhost:9112/info
```
