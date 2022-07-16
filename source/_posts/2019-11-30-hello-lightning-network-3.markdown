---
layout: post
title: "Hello Lightning Network -3"
date: 2019-11-30 09:12:24 +0800
comments: true
categories: blockchain lightning
---


在前面几篇文章中我们评论道：闪电网络是一个丰富的生态，将来里面会有各种各样的角色参与其中；目前来看，如何注入足够Inbound Capacity，保持闪电网络有充裕的流动性似乎是个棘手问题；而且不少人攻击这最终会导致比特币运营中心化；

为了理解这个问题，我们对于闪电网络的原理做了详细的探讨，现在是谈谈社区的一些解决方案的时候了；

我们这篇文章就来探讨为了解决Inbound Capacity问题，目前lightningLab的一个实验项目：

[loop](https://github.com/lightninglabs/loop)

<!-- more -->

#### 再次回忆Inbound Capacity

想一下，我们什么时候需要注入Inbound Capacity；简单来说，有两种典型的场景：

1. 商家收款，Inbound Capacity消耗殆尽
2. 小白初次体验闪电钱包，向朋友收款，需要开辟第一个收款通道

在一个人人都使用闪电的理想未来中，这个系统是自平衡的。你付给别人的钱和你从他们那里得到的钱一样多，而资金只是不停地来回流动。然而，在今天的闪电网络状态下，这并不符合实际情况。例如，一个商人通过闪电销售产品，但通过另一种支付方式支付其供应商可能会积累越来越多的平衡在其闪电渠道，直到客户不能再支付。所有的资金都移到了商人那边。

现在最普遍的解决办法就是向三方服务商购买通道服务。这就造成了一个让比特币老手匪夷所思的疑问：不是说闪电网络好用吗？怎么收个款这么折腾？难道我要收款，还得先求别人来给我铺路？

为什么我不能自己动手，丰衣足食呢？还有，假如我是商家，收款的时候还得时时操心额度够不够，这不是折腾吗？

这是非常正常的质疑，因此我们一再说闪电网络还处于发展期，有很多基础设施不够完善；

## LOOP

* 在我们的想象中，闪电网络应该提供这样一种服务：

让用户能够用来自钱包或交易所的链上比特币来填充他们的闪电通道。当用户通过闪电网络进行一系列支付时，她的Inbound 余额就会下降。然后，她可以使用这个服务从一个普通的比特币链上钱包或通过一个交易所账户，在闪电通道上重新注入资金，并在必要时继续增加额外的资金。

这项服务还应该允许用户使用非托管的比特币合约，安全地将资金从闪电网络中转移到其他地方。有了LOOP，用户、企业和路由节点运营商就能够无限期地保持闪电通道的开放，从而使网络更高效、更稳定、使用更便宜。

在这个场景中，不论是用户的链上钱包，还是闪电通道，只要还有余额，就能没有感知的继续付款和收款，直到余额消费完毕为止；

用户的体验应该是打开钱包，即可完成每一笔支付和收款交易，而不用去操心通道余额，Inbound Capacity这些烦心问题；

要做到这些，Loop的解决方案是利用闪电通道付款(把资金从你这边推出)，然后在一个链上地址收到钱。你有效地将支付循环回你自己，因此得名闪电循环(Loop)。

任何通道都可以反复循环。不需要打开新的通道，用户可以选择他们想要循环出去的对等点。这是与“销售”服务和用户之间的通道的现有服务相比的一个优势。

有了这些服务，任何支付给用户的收入将支付路由费用。它们绑定到目标服务的路由策略。除此之外，许多用户使用相同的服务打开通道会造成单点故障。客户端Lightning Loop软件和协议是开源的，并且是经过mit许可的，而服务器端则可以通过使用比特币合约来完全验证。

我们当然可以成立一个托管方来完成一切操作，但是，在去中心化的背景下，为每一个用户提供这样的能力也是非常重要的；让我们看看Loop是如何做到这一切的；

#### 一个最基本的LOOP循环

一个最基本的LOOP循环包含下面这几个步骤：

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20191130/bg1.jpg)

我们假设商家的名字叫Bob，他想用自己的链上钱包充值一个闪电通道，他连接到了一个LOOP服务，这个LOOP服务可以是Bob自己架设，也可以是不需要信任的第三方假设的；

1. Bob生成一个秘密散列预原像值R，以及散列结果H
2. Bob将与此散列H绑定的付款发送到Lightning Loop服务器。服务器还不能消费这笔款项，因为它还不知道R。相反，它会一直持有这笔支付交易，直到它得到原像R。此部分使用hodl发票实现。
3. 服务器将一个链上事务发布到一个输出(交易C1a)，该输出可以通过公开原像R(一笔P2SH交易)来消费，这是一笔链上的HTLC交易
4. Bob将监控到这笔交易，他提供了R值消费了这笔交易(称为sweep tx)，此时R值成为一个公共知识
5. 服务器同样监控到这笔交易的消费，它从其中提取R值，并使用它来处理它仍然持有的闪电支付。最后一步完成交换。

如果服务器保留闪电支付，并且从不发布链上事务，那么支付将超时，资金将返回给用户。这构成了服务的非托管性质。在超时的情况下，用户会受到轻微的惩罚，因为Loop将锁定他们的资金直到超时。

#### 预付款

LOOP服务器需要花钱构造一个HTLC 链上交易。如果Bob不消费这笔交易，LOOP服务器将失去这笔钱。如果不进行检查，这可能会引入一个DoS攻击方法，将循环系统的空闲UTXOs消耗一空。

为了防止这种情况发生，Bob需要在交换付款的同时进行第二次闪电付款，称为预付款(prepayment)。这个想法是，如果交换没有成功，但是服务器发布了链上 HTLC(C1a)，服务器保留预付款作为对矿商费用损失的补偿。

#### Bob消费链上HTLC

当Bob的消费HTLC(C1a)的交易进入mempool(上面的步骤4)时，就会显示原像R值。从那时起，原像R将被视为公共知识，Bob应该期待他们的闪电付款尽快成功确认。正是出于这个原因，Bob需要确保消费交易得到确认。有一件事可能会延迟确认，那就是以过低的矿商费发布消费交易。但是，用户可以使用诸如RBF和CPFP等费用提升工具来确保及时的确认。

在Lightning Loop中，通过启用RBF并尝试用基于最新费用估计的新交易替换每个块中的sweep交易来处理未确认的交易风险。交易费用的上限是用户在开始交换时指定的最大矿商费用，以避免在链上支付过高的费用。


#### 时间压力

不幸的是，对于用户Bob来说，确认扫描交易的时间是有限的。LOOP服务器需要一种方法，如果Bob没有发布R值来消费这笔链上交易C1a，服务器也可以收回资金。因此，链上交换输出同时被一个散列和一个时间锁定，这使得它成为一个类似于常规闪电支付中使用的HTLC的hashtime locked contract (HTLC)。

当交换被启动时，服务器会选择HTLC的实际到期高度，并根据循环客户端实现可接受的最小值进行检查。如果服务器建议的到期时间太短，将不会构造C1a，并且交换将终止。这样做的原因是，用户需要有一个合理的机会来确认C1a的消费交易。

当用户通过在内存池中插入消费交易来公开原像R时，计时器开始计时。用户需要在达到到期高度并打开服务器回收路径之前确认交易。

当Bob公布了R值，但他的消费交易却因为费用太低而迟迟无法确认，当接近到期高度时，Bob可能需要更积极地提高收费。他甚至可能想要超过设定的最大矿商费，因为另一种选择可能是失去全部掉期金额。


#### 服务器如何保证公正

LOOP的目标是以一种不考虑服务器行为的方式实现它。它应该考虑服务器作恶的情况。例如，从服务器接收到的所有值和on-chain HTLC的参数都由客户机在本地进行检查。如果任何操作超出了可接受的范围，则LOOP交换将中止。

尽管做了这些准备，但Loop还实现了一个“公平”的服务器。只要对方可以选择不同的行为，LOOP Server就会选择对用户最有利的行为。相对的，有些对手服务器会抓住任何机会来最大化利润。由于掉期是非托管性的，幸运的是，这样的机会并不多。它们大多出现在用户不愉快的流程和错误方面。

取消掉期支付就是一个例证。当链上的HTLC过期且超时交易得到充分确认后，服务器需要收回资金时，将立即取消所持有的通道中的付款。它本来可以持有它更久，希望由于某种原因，原像R仍然会出现在mempool当中，但公平的服务器不会这样做。


#### 递归循环

有了LOOP，就有可能使用一定数量的资金X来获得比X大得多的流入流动性。用收到的链上基金，可以注入到打开的另一个通道中去，这个通道的资金也可以循环出去。只要还有资金，这个过程就可以继续下去，因为每一步都需要向矿工、路由节点和循环服务支付费用。这个方法称为“环回”。

这样做的最终结果是，路由节点会向用户的节点提交大量资金。对他们来说，希望他们能从中赚取一些路由费用。

这也强调了路由节点监视它们的通道并关闭不产生任何返回的通道的必要性。


将链上资金注入闪电通道的行为我们称之为 LoopIn，将闪电通道的资金支付回链上钱包的行为我们称之为LoopOut。

Bob的LoopIn只可以为自己的通道注资，来源资金可以来自自己的钱包，也可以通过指定一笔外部的on-chain HTLC交易给通道注资；如果某个交易所支持这种Loop方式，也许将来你可以直接从交易所托管的在线钱包中提取资金到你的闪电通道中；

而LoopOut既可以付款给自己，也可以指定一个三方钱包地址，这在发工资的时候可能很有用；

#### 缺陷

为了防止DoS攻击，使用LOOP服务需要一笔预付款。预付款数额是名义上的，最多是几千satoshis。在API和CLI中，执行交换的用户可以预先看到他们同意的预付金额。

除此之外，还需要使用HTLCs对传入和传出的CLTV输出进行标准超时处理。这与Lightning中所需的时间锁管理级别没有什么不同。然而，良好的费用选择启发式的影响可以降低到最低。


#### 结论

可以看到，与循环输出提供的独特优势相比，上述几点缺陷微不足道。它为用户提供了从任何人获得流入流动性的灵活性。它不会推动集中式的网络拓扑结构，并提供了重用现有通道的方法，从而延长了通道的生存期。


## 实践

#### 架设一个LOOP服务

Loop目前只能跟lnd搭配使用，我们在同一台机器上，模拟Bob商户，在不需要别人帮助的情况下为自己的闪电通道Inbound注资；

* lnd的编译需要特殊开关才能支持loop:

```
git clone https://github.com/lightningnetwork/lnd.git
cd lnd
make install tags="signrpc walletrpc chainrpc invoicesrpc routerrpc"
```

* 启动lnd

```
nohup ./lnd --bitcoin.active --bitcoin.testnet --debuglevel=debug --bitcoin.node=bitcoind --bitcoind.rpcuser=xxxxx --bitcoind.rpcpass='xxxxx' --bitcoind.zmqpubrawblock=tcp://127.0.0.1:28332 --bitcoind.zmqpubrawtx=tcp://127.0.0.1:28333 --listen=0.0.0.0:9736 --externalip=x.x.x.x 2>&1 > lndtest.log &
```

启动之后你会发现多了几个macaroon验证文件，关于macaroon，我们以后会写文章介绍；

```
ls ~/.lnd/data/chain/bitcoin/testnet/
admin.macaroon  chainnotifier.macaroon  channel.backup  invoice.macaroon  invoices.macaroon  macaroons.db  readonly.macaroon  router.macaroon  signer.macaroon  wallet.db  walletkit.macaroon
```

* 如果没有闪电通道的话，建立一个闪电通道，此步骤参考之前的文章

* 编译loop

```
git clone https://github.com/lightninglabs/loop.git
cd loop/cmd
go install ./...
```

编译之后会得到两个可执行文件，服务程序loopd，以及命令行cli交互工具loop;

* 启动loopd

```
nohup loopd >> loopd.log 2>&1 &
```

* 将链上钱包的钱注入到已有的闪电网络通道中

因为我们是自助服务，所以我们使用loop out提取一部分链下的资金，回收到自己的链上钱包中，同时为自己的通道注入流动性

在注入之前，我们已经建立了一个持有1000000 satoshi的通道，不过这1000000 satoshi都在我们自己`local_balance`一端，我们的`remote_balance`此时是0；

我们执行

```
./loop out 500000 tb1q3d8l6wgqprl7xxxxxxxxxxxxxxxxxxx
./loop monitor
```

持续监控log输出，我们发现此时通道状态变成了这样：

```
channel:
    "channels": [
        {
            "active": true,
            "remote_pubkey": "xxxxx",
            "channel_point": "zzzzzz:1",
            "chan_id": "111111111111",
            "capacity": "1000000",
            "local_balance": "498627",
            "remote_balance": "0",
            "commit_fee": "271",
            "commit_weight": "944",
            "fee_per_kw": "253",
            "unsettled_balance": "501102",
            "total_satoshis_sent": "0",
            "total_satoshis_received": "0",
            "num_updates": "21",
            "pending_htlcs": [
                {
                    "incoming": false,
                    "amount": "1338",
                    "hash_lock": "eO+/AlX7HUR5UblpmTPh8JzU6Uq7LN5026k8TAebFx8=",
                    "expiration_height": 1609844
                },
                {
                    "incoming": false,
                    "amount": "1338",
                    "hash_lock": "eO+/AlX7HUR5UblpmTPh8JzU6Uq7LN5026k8TAebFx8=",
                    "expiration_height": 1609844
                },
                {
                    "incoming": false,
                    "amount": "499764",
                    "hash_lock": "+xsofcSn9Y+Wx94vkx66rl5rgQoDthVBI4Pvhp6lhX4=",
                    "expiration_height": 1609988
                }
            ],
            "csv_delay": 144,
            "private": false,
            "initiator": true,
            "chan_status_flags": "ChanStatusDefault",
            "local_chan_reserve_sat": "10000",
            "remote_chan_reserve_sat": "10000",
            "static_remote_key": false
        }
    ]
}

```

通道中现在有了htlc交易，并设定了一个过期块高度;

此时loopd的输出如下：

```
2019-11-24 10:58:48.403 [INF] LOOP: Offchain swap destination: xxxxxxxxxxxxxxxxxxxxxxxxxx
2019-11-24 10:58:53.073 [INF] LOOPD: Loop out request received
2019-11-24 10:58:53.073 [INF] LOOP: LoopOut 0.005 BTC to tb1q3d8l6wgqprl7xxxxxxxxxxxxxxxxxxx (channel: <nil>)
2019-11-24 10:58:53.078 [INF] LOOP: Initiating swap request at height 1609561
2019-11-24 10:58:53.423 [INF] LOOP: fb1b28 Htlc address: tb1qku40cmlsrmdtyqp6vgpjw9vpe8jkcp3ullxa9u5yphpdequc6f4qa60ts8
2019-11-24 10:58:53.424 [INF] LOOP: fb1b28 state Initiated
2019-11-24 10:58:53.425 [INF] LOOP: fb1b28 Sending swap payment lntb4992630n1pwanu0dpp5lvdjslwy5l6cl9k8mchex8464e0xhqg2qwmp2sfrs0hcd849s4lqdq8wdmkzuqcqzxgxq97zvuqv0cxf7zfatl4tx5jqkvlxrv8rz8jkjcynm0rezjq5swdvrnh8fs4znp256uxy3rdvdtgvgd9sfj8gz9jaghw82stu06xf94ph3nt5xcqw5sugm (id:fb1b287dc4a7f58f96c7de2f931ebaae5e6b810a03b615412383ef869ea5857e)
2019-11-24 10:58:53.425 [INF] LOOP: fb1b28 Sending prepayment lntb13370n1pwanu0dpp50rhm7qj4lvw5g723h95ejvlp7zwdf622hvkduaxm4y7ycpumzu0sdq2wpex2urp0ycqzxgxq97zvuqkhdq3yvlvljdkz2h3u5s37q2h6mxt4w3ynucnf6psckwpc80l3y944h09ruj2m2zacyshuch7hdwzl86n6nva0lan8lyg3rhshqsn0qprgdyel (id:78efbf0255fb1d447951b9699933e1f09cd4e94abb2cde74dba93c4c079b171f )
2019-11-24 10:58:53.425 [INF] LOOP: fb1b28 Register conf ntfn for swap script on chain (hh=1609561)
2019-11-24 10:58:53.425 [INF] LOOP: fb1b28 Checking preimage reveal height 1609641 exceeded (height 1609561)
2019-11-24 10:58:53.425 [INF] LOOP: fb1b28 Waiting for either htlc on-chain confirmation or  off-chain payment failure

```

注意，这里产生了两笔闪电支付，分别是注入通道的资金(swap payment)，以及预付款(prepayment)；Loop服务端立即发布了链上交易，期待得到swap payment的原像R值；

然后我们等待链上交易的确认:

```
2019-11-24 10:59:02.029 [INF] LOOPD: Monitor request received
2019-11-24 11:10:41.583 [INF] LOOP: Received block 1609562
2019-11-24 11:10:41.585 [INF] LOOP: fb1b28 Checking preimage reveal height 1609641 exceeded (height 1609562)
2019-11-24 11:28:10.032 [INF] LOOPD: Loop out terms request received
2019-11-24 11:28:10.091 [INF] LOOPD: Loop in terms request received
2019-11-24 11:28:53.934 [INF] LNDC: Payment 78efbf0255fb1d447951b9699933e1f09cd4e94abb2cde74dba93c4c079b171f completed
2019-11-24 11:29:36.256 [INF] LOOPD: Monitor request received
2019-11-24 11:30:27.928 [INF] LOOP: Received block 1609563
2019-11-24 11:30:27.929 [INF] LOOP: fb1b28 Checking preimage reveal height 1609641 exceeded (height 1609563)
2019-11-24 11:30:27.929 [INF] LOOP: fb1b28 Swap script confirmed on chain
2019-11-24 11:30:27.929 [INF] LOOP: fb1b28 Htlc tx eac746dd4c7f28edd277a39aa4771b651f0faf1d11f82bacf03e668b35a5658b at height 1609563
2019-11-24 11:30:27.929 [INF] LOOP: fb1b28 Htlc value: 0.005 BTC
2019-11-24 11:30:37.939 [INF] LOOP: fb1b28 state PreimageRevealed
2019-11-24 11:30:37.939 [INF] LOOP: fb1b28 Sweep on chain HTLC to address tb1q3d8l6wgqprl7tgtgwlqcxq8fts8vf5cwezww9s with fee 0.00000138 BTC (tx 2edcbe792641e4e6aff8dd83b8a5d8ee3cf4cba158b2ee05b3111ccadbbe13fc)
2019-11-24 11:45:01.137 [INF] LOOP: fb1b28 Htlc spend by tx: 2edcbe792641e4e6aff8dd83b8a5d8ee3cf4cba158b2ee05b3111ccadbbe13fc
2019-11-24 11:45:01.137 [INF] LOOP: fb1b28 Wait for server pulling off-chain payment(s)
2019-11-24 11:45:01.841 [INF] LNDC: Payment fb1b287dc4a7f58f96c7de2f931ebaae5e6b810a03b615412383ef869ea5857e completed
2019-11-24 11:45:01.841 [INF] LOOP: fb1b28 Swap completed: Success (final cost: server 0.000006 BTC, onchain 0.00000138 BTC, offchain 0.00000502 BTC)
2019-11-24 11:45:01.842 [INF] LOOP: fb1b28 state Success
```

客户端迅速消费了链上交易，一个区块确认之后，整个交换过程完成：

```
success swap payment:

        {
            "payment_hash": "fb1b287dc4a7f58f96c7de2f931ebaae5e6b810a03b615412383ef869ea5857e",
            "value": "499263",
            "creation_date": "1574564333",
            "path": [
                "03052ae5c77d75264a13ab0d34520bd8260de9542e7d930cbe6bc5137485f065f3",
                "03d5e17a3c213fe490e1b0c389f8cfcfcea08a29717d50a9f453735e0ab2a7c003",
                "03fe1c271da46da5cf632beb84551c4100064d830b89dc46f8975123803cc93ff3",
                "0223acffd7f363b4591ce860eda870fea352e981212d8a25e96a0ebea37faae288"
            ],
            "fee": "501",
            "payment_preimage": "b975dc85897b707865dcff54b96511568f86622c89020a2678171e083001717a",
            "value_sat": "499263",
            "value_msat": "499263000",
            "payment_request": "lntb4992630n1pwanu0dpp5lvdjslwy5l6cl9k8mchex8464e0xhqg2qwmp2sfrs0hcd849s4lqdq8wdmkzuqcqzxgxq97zvuqv0cxf7zfatl4tx5jqkvlxrv8rz8jkjcynm0rezjq5swdvrnh8fs4znp256uxy3rdvdtgvgd9sfj8gz9jaghw82stu06xf94ph3nt5xcqw5sugm",
            "status": "SUCCEEDED",
            "fee_sat": "501",
            "fee_msat": "501762"
        }

```

此时的通道状态:

```
{
    "channels": [
        {
            "active": true,
            "remote_pubkey": "xxxxx",
            "channel_point": "zzzzzz:1",
            "chan_id": "111111111111",
            "capacity": "1000000",
            "local_balance": "498714",
            "remote_balance": "501102",
            "commit_fee": "184",
            "commit_weight": "724",
            "fee_per_kw": "253",
            "unsettled_balance": "0",
            "total_satoshis_sent": "501102",
            "total_satoshis_received": "0",
            "num_updates": "23",
            "pending_htlcs": [
            ],
            "csv_delay": 144,
            "private": false,
            "initiator": true,
            "chan_status_flags": "ChanStatusDefault",
            "local_chan_reserve_sat": "10000",
            "remote_chan_reserve_sat": "10000",
            "static_remote_key": false
        }
    ]
}
```

我们loop循环出通道的一半资金返回到我们的链上钱包，同时在通道另一端注入了流动性；总体花费：

1. pre payment 费用
2. on-chain HTLC 矿工费
3. on-chain HTLC 花费交易(sweep tx)的矿工费


最后，我们自立更生，为一个通道注入的Inbound流动性。


## 小结

与比特币刚出现时的情况一样，整个过程漫长而枯燥，批评者会说：哦，太麻烦了，太糟糕了；我不能想象会有人用这种东西！！

不要着急，LOOP技术为闪电网络通道的资金管理提供了无限的可能性；个人运行一个LOOP Server的成本非常低，并且可以想象，在闪电网络的极大繁荣期，并不是只有大公司才能以极大的资金量提供闪电通道的服务，小商家通过精细的运营和筹划，在安全保证本金的前提下，运营一个 LOOP节点来获得手续费用，其性价比会超过运营一个超大规模的闪电节点；就像换汇一样，如果开放自由市场，国家控制的大银行无疑在换汇服务中有极大的优势，但能提供更低廉、更方便的换汇服务的，往往是街头不起眼的小商小贩；

不要因为它现在只是一棵幼苗而轻视它，也许二十年后，它会成长为一棵参天大树。

#### 饥渴求知，虚怀若愚(Stay Hungry, Stay Foolish)


#### 引用

https://blog.lightning.engineering/posts/2019/03/20/loop.html

https://blog.lightning.engineering/technical/posts/2019/04/15/loop-out-in-depth.html

https://blog.muun.com/the-inbound-capacity-problem-in-the-lightning-network/

https://github.com/lightningnetwork/lightning-rfc

https://blog.lightning.engineering/posts/2018/05/30/routing.html
