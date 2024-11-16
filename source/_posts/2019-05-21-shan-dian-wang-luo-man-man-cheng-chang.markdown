---
layout: post
title: "闪电网络慢慢成长"
date: 2019-05-21 09:44:25 +0800
comments: true
categories: blockchain lightning
---
学习一件事情的最好办法就是尽可能去用。

我在Bitcoin Testnet上面运行一个LND全节点已经有很长时间了，对现在闪电网络的进化速度都有了直观的体验：`积跬步，至千里`；

<!-- more -->

首先必须先承认，现在要完整的体验闪电网络，即从后台构建+前端使用整个流程，是非常麻烦的，恐怕只有对其原理有比较深入了解的人才能完成这个过程；简单说一下:

#### 1.需要Linux环境

#### 2.需要运行一个bitcoin全节点，因为都是命令行操作，所以要`手工创建钱包` -> `转账确保钱包有余额`

* bitcoin.conf的配置文件模板


```
rpcuser=xxxxx
rpcpassword=xxxxx
rpcallowip=127.0.0.1/16
rpcport=18332
test.rpcport=18332
rpcthreads=10
server=1
rest=1
testnet=1
zmqpubrawblock=tcp://127.0.0.1:28332
zmqpubrawtx=tcp://127.0.0.1:28333

```

* 启动bitcoind


```
bitcoin/bin/bitcoind --conf=~/bitcoin.conf --datadir=/opt/bitcoin/blockdata/ 

```

* 同步后找到当前钱包收款地址


```
bitcoin-cli listaddressgroupings

```

* 发送一笔转账到此地址，也可以直接去[bitcoinfaucet](https://bitcoinfaucet.uo1.net/send.php)领一些测试币

* 确认钱包余额


```
bitcoin-cli getwalletinfo

```

#### 3.运行一个LND Daemon

这方面有几个主流选择，lightning labs的[lnd](https://github.com/lightningnetwork/lnd)，或者[c-lightning](https://github.com/ElementsProject/lightning)，或者[lit](https://github.com/mit-dci/lit)

lnd支持比较广泛，我们用其0.6beta版本搭建；

* 按照项目文档构建Go编译环境，编译生成lnd和lnd-cli两个可执行文件
* 启动lnd daemon(注意这里没有启用验证，在mainnet上面切不可这么做)


```
lnd --bitcoin.active --bitcoin.testnet --debuglevel=debug --bitcoin.node=bitcoind --bitcoind.rpcuser=xxxxx  --bitcoind.rpcpass='xxxxx' --bitcoind.zmqpubrawblock=tcp://127.0.0.1:28332 --bitcoind.zmqpubrawtx=tcp://127.0.0.1:28333 --no-macaroons

```

* 之后lnd会通过bitcoind node同步区块头，大概需要10分钟
* 创建lnd的钱包，保存seed，便于之后恢复


```
lncli --network=testnet create

```

* 创建一个segwit地址


```
lncli --network=testnet newaddress np2wkh
2NF5UC1ZgQzb8Ustm9JCTbQQTU5Ca438WWf

```

* 打一些测试币给这个地址


```
/bitcoin-cli sendtoaddress 2NF5UC1ZgQzb8Ustm9JCTbQQTU5Ca438WWf 0.005

```

* 看一下钱包信息，收到款没有


```
lncli --no-macaroons --network=testnet walletbalance

```


#### 4. 建立通道

* 直接到[1ml.com](https://1ml.com/testnet/)找最近连接数最多的节点, 比如[Node: aranguren.org](https://1ml.com/testnet/node/038863cf8ab91046230f561cd5b386cbff8309fa02e3f0c3ed161a3aeb64a643b9):


```
node ID:038863cf8ab91046230f561cd5b386cbff8309fa02e3f0c3ed161a3aeb64a643b9@203.132.95.10:9735

```

* 连接这个节点：


```
lncli --no-macaroons --network=testnet connect 038863cf8ab91046230f561cd5b386cbff8309fa02e3f0c3ed161a3aeb64a643b9@203.132.95.10:9735

```

* 建立通道，放一笔钱进去


```
lncli --no-macaroons --network=testnet openchannel --node_key=038863cf8ab91046230f561cd5b386cbff8309fa02e3f0c3ed161a3aeb64a643b9 40000

```

* 需要一段时间同步，然后看一下通道状态:


```
lncli --network=testnet listchannels

```


#### 5. 支付 

* 首先到[testnet.satoshis.place](https://testnet.satoshis.place/)涂鸦两笔，得到一个支付地址:


```
lntb1pwwykwhpp5jw4tekxmsqjwepw4070em7xe7gw3v8mxtenexmsp2np3pcc40jwqdqqxqruyqrzjqfcxsh9gr28y6ngphmk90q05ejfydpq89tjjc5rl36lfmtcv424hk9e8sgqqqvsqqqqqqqlgqqqqqeqqjqjpfnq26e2flenp79ywpyyftg3najf3wtpvkwuuw2h9y3dzdn7kc3342h6uzgf69ms8sx6fxsh5j2jcwzulr3dufryn9ljadm0wuj9fcpm86fax

```

* lnd-cli支付


```
lncli  sendpayment --pay_req lntb1pwwykwhpp5jw4tekxmsqjwepw4070em7xe7gw3v8mxtenexmsp2np3pcc40jwqdqqxqruyqrzjqfcxsh9gr28y6ngphmk90q05ejfydpq89tjjc5rl36lfmtcv424hk9e8sgqqqvsqqqqqqqlgqqqqqeqqjqjpfnq26e2flenp79ywpyyftg3najf3wtpvkwuuw2h9y3dzdn7kc3342h6uzgf69ms8sx6fxsh5j2jcwzulr3dufryn9ljadm0wuj9fcpm86fax 500

```

#### 6. 收款

lnd构建一个收款节点比较麻烦，我们可以借助一个实现了lnd hub全功能的钱包来体验，推荐 [elcair](https://github.com/ACINQ/eclair)；

[BlueWallet](https://bluewallet.io/)也是一个非常受欢迎的闪电网络钱包，不过他并没有实现完整的lightning hub的功能，作为想要完全掌控一切的玩家不太合适，当然对于普通用户来说，BlueWallet更易用：

https://medium.com/bluewallet/bluewallet-brings-zero-configuration-lightning-payments-to-ios-and-android-30137a69f071

* 关于 elcair如何构建一个收款地址的过程，可以参考:

https://medium.com/@ACINQ/enabling-receive-on-eclair-mobile-2e1b87bd1e3a

* 老实说，使用elcair的过程也需要一点技术，至少要搞明白我们之前讲述闪电网络技术原理的那篇文章


#### 7. 总结

好啦，相信小白看到这里已然头昏眼花，并发出怒吼：这么复杂的东西谁会用啊！

我得说，在使用闪电网络的过程中，我体会到了巨大的乐趣，就跟我第一次手工完成一笔比特币交易一样的乐趣！

回想互联网之初，发个电子邮件也需要精通命令行操作的`专家人士`来完成，跟现在闪电网络的使用体验完全一样！

我也相信随着产业发展，这项技术迟早会变得跟电子邮件一样，在IPAD上动动手指就完成一切，我憧憬着这一天。


然后我们看一下现在闪电网络面临的一些技术和实务上的挑战：

1. 目前还没有完全靠谱的，敢于宣称可安全用于生产的基础软件实现，大家都在beta版
2. 目前运行一个lnd，需要配置一个bitcoin fullnode，而且是一对一的，成本比较高，虽然运行一个全节点可以取得一些手续费，但是其风险和收益不成对比；bitmex有[一篇文章](https://blog.bitmex.com/the-lightning-network-part-2-routing-fee-economics/)详细分析了现在运行一个闪电网络节点的收益情况；
3. 现在lit项目和Neutrino项目都朝着`运行一个支持闪电节点的SPV节点`这个方向努力，但距离完成还有很长时间；
4. 在我们之前的文章分析中，每一个钱包，都需要一个类似`瞭望塔`的模块，来监控通道的状态；围绕这个实现，目前有两大流派：一类就是elcair 钱包自己继承这个功能，这就要求用户的钱包不能脱离网络超过两周；第二类就是BlueWallet的实现，让用户放弃掌控一切，由钱包服务商托管；这两种方案各有优劣，之后还要看市场和众多黑客们的测试结果；
5. Electrum目前也在进行闪电网络的实现，他们采用了改造ElectrumX server端，增加一个和lnd连接的中间通讯层的方法，并且ElectrumX是可以复用的，以后如果lnd实现了Neutrino，可以完成`ElectrumX+Lnd+Neutrino`的部署，估计这样成本低，运营的好的话，能赚点小钱；


最后的最后：

* 闪电网络的成长目前是一个非常壮丽的场景，堪比互联网发展之初；

* 终于出现了这样一种基础金融技术:
    - 可以支持个人开银行，没有任何法律、宗教、地域、政府的隔阂；
    - 只要有网络和你的信用，就可以面向全球用户做一个银行家；
    - 而且你的银行没有柜台、没有繁琐的开户流程，没有金碧辉煌的大楼，只需要一个联网的手机而已；但这是世界上最讲信用的，最具有扩展性的，最安全的银行；
    - 你的用户也无需繁琐的身份证明，政策限制，高昂的手续费，屈服于传统银行的被冻结账户的风险，甚至都不需要物理的货币和钱包，只需要在脑子里记住一串密语而已；而对于将来的那些`世界银行家`来说，你的信用就是一切。酷!!!
