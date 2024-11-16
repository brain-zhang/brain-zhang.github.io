---
layout: post
title: "bitcoin-cli cheat"
date: 2018-10-26 16:28:23 +0800
comments: true
categories: blockchain
---

今天踩了一个巨坑。

我一直以为`bitcoin-cli sendfrom`命令是可以花费uncomfirmed UTXO的。

<!-- more -->

然后今天发现bitcoin-core 0.17版本已经开始废弃这个命令和`bitcoin account`的支持了。于是去修改万年之前的一个脚本。

然后我切换到TESTNET里面发了几笔交易，惊奇的发现sendfrom并不能花费uncomfirmed UTXO。执行:


```
> bitcoin-cli sendfrom "" "1M72Sfpbz1BPpXFHz9m3CdqATR44Jvaydd" 0.01 0

```

明明我已经发给测试账户0.1BTC过去了，getwalletinfo可以看到这个币了，我也把minconf设为0了，却在执行sendfrom的时候总是提示我`Account has insufficient funds`；

我一路代码追下去，在这里:

https://github.com/bitcoin/bitcoin/blob/e44150feed53317677b1e2073f3cb0cfc67b691c/src/wallet/rpcwallet.cpp#L915

惊奇的发现只有自己的找零才会在uncomfirmed的情况下被计入credit fund，震惊了。我这个脚本运行了半年了，才发现这个坑。

没办法，自己又封装了一遍`createrawtransaction`，`signrawtransaction`, `sendrawtransaction`，来代替sendfrom的功能。

找这个问题我在TESTNET里面发了不下一百笔交易，wallet部分的代码已经翻遍了，我深深为之感叹bitcoin core实现wallet这部分的精巧，好多地方的细节已经不是人类能理解的了；太可怕了。

另外记一下远程调用bitcoind rpc接口的套路:


```
>bitcoin_cli --rpcconnect=192.168.2.7 --rpcpassword="xxxxx" --rpcuser=test getwalletinfo

```

相应的，bitcoin.conf也要允许远端调用rpc接口的权限:


```
rpcuser=test
rpcpassword=xxxxx
rpcallowip=192.168.2.0/255.255.255.0
rpcport=8332
rpcthreads=10
server=1


```

ps: bitcoin.conf 可以直接放到blockchain的数据目录，反正我看0.15的代码，已经把这个路径默认加到path搜索里面了。
