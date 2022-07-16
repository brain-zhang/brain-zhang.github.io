---
layout: post
title: "Hello Lightning Network -1"
date: 2019-11-05 17:17:48 +0800
comments: true
categories: blockchain lightning
---

有许多比特币社区的先行者们面对小白的提问时，总是真诚的说：“去看看比特币的白皮书吧，把它真正弄明白吧，你就会理解一切的。” -----如今，我想对许多质疑闪电网络的比特币先驱们说：“去看看闪电网络的白皮书吧，把它真正弄明白吧，你就会理解一切的。”
{:.info}

我们之前写文章评价道，闪电网络是次世代的支付技术，它不仅仅是一个支付技术，更是建立在比特币主网上的二层网络协议，将来会有许许多多新奇的应用建立在上面，它会为比特币开启下一个十年；

但是闪电网络还在实现的早期阶段，能耐心去读懂它的白皮书的人已经非常少了，更不用提现在飞速发展的[BOLT规范](https://github.com/lightningnetwork/lightning-rfc/)了；这其实跟比特币刚诞生时是一样的，在动辄就大谈“区块链技术改变未来”的那一群人中，有几人会真正花时间，去把已经发表11年的比特币8页白皮书弄个明白呢？

闪电网络的基本原理其实非常简单，在我们之前的文章中已经花费了大量篇幅去介绍；但是在实现过程中，还有数不清的工程细节上的权衡；由于现在的实现还只是一个雏形，我们实操闪电网络交易的时候会有各种各样的“？”，我打算写一个系列文章，把一些有趣或者让人困惑的地方抽丝剥茧，记录一下自己的学习过程，也把这项迷人的技术介绍给更多人。

我们将在这篇文章中讨论闪电网络的通道入站容量(Inbound Capacity)问题。

<!-- more -->

凡是亲身体验闪电网络钱包的人，都是这样一个过程:

1. 发送小额的比特币给钱包链上地址
2. 连接到一个闪电网络节点，创建一个通道，并放置一些币到通道中；
3. 通过闪电网络发送一笔支付交易

到目前为止，一切顺利(当然，对于技术小白来讲，这三个步骤已经足够艰辛了)；然后他会立即遇到闪电网络中第一个令人困惑的问题：

* 我如何收款？

在解决这个问题之前，我们需要复习一些基础知识；你会惊奇的发现，我们前文所说的`工程上的细节`到底是多么细节的东西；

#### 本地余额与远程余额 (local balance and remote balance)

当我们初次建立一个支付通道时，用`lncli listchannels`探测，一般必要信息是这样的:

```
        {
            "active": true,
            "remote_pubkey": "xxxxxxxxxx",
            "channel_point": "zzzzzzzzzz:0",
            "chan_id": "17405554940800000000",
            "capacity": "279359",
            "local_balance": "279176",
            "remote_balance": "0",
            "commit_fee": "183",
            "commit_weight": "600",
            "fee_per_kw": "253",
            "unsettled_balance": "0",
            "total_satoshis_sent": "0",
            "total_satoshis_received": "0",
            "num_updates": "48",
            "pending_htlcs": [
            ],
            "csv_delay": 144,
            "private": false,
            "initiator": true,
            "chan_status_flags": "ChanStatusDefault",
            "local_chan_reserve_sat": "2793",
            "remote_chan_reserve_sat": "2793",
            "static_remote_key": false
        },
```

我们先来关注一下 `local_balance`和`remote_balance`这两个参数；

如果还记得我们之前的[科普文章](https://brain-zhang.github.io/blog/2019/01/06/bi-te-bi-de-jiao-yi-7/)的话；构建闪电通道的第一个步骤是建立一笔Funding TX；
这需要双方拿出一定量的比特币放入通道中，这样就会有固定数量的比特币被锁定到通道中，称为通道容量(capacity); 通道发起方投入的金额称为本地余额(local_balance)，对端投入的金额称为远程余额(remote_balance)；

在上面这个例子中，我们看到作为通道发起方，local_balance是279176 satoshi，remote_balance是0，代表对端仅仅是跟我们建立通道链接，并没有放币进来；

local_balance和remote_balance可以在不关闭通道的情况下多次更新，但是如果不关闭或者拼接通道，通道容量无法更改；

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20191106/bg0.png)

>我们可以把它想象成一个沙漏，虽然沙子的总量是固定的，但是我们可以在沙漏的上下部之间移动啥子，如果想要改变沙子的总量，就需要打破沙漏；

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20191106/bg1.png)

>如图：以你的视角来看，你和ROBERT的通道容量是8 btc, local_balance是5btc，remote_balance是3btc; 以ROBERT的视角来看，他的local_balance是3btc，remote_balance是5btc


每次你付款时，都会把local_balance的部分余额推给对端的ROBERT。 同样的，当收到一笔付款时，local_balance也会增加，remote_balance会减少；

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20191106/bg2.png)

>如图：当你支付ROBERT 1BTC时，你的local_balance减少1BTC，而remote_balance增加1BTC;


回到我们最初的例子，因为remote_balance的余额是0 satoshi，所以在只有这一个通道的情况下，你最多发送279176 satoshi，却无法接受付款；

可能聪明的你已经想到了，作为主动发起通道连接的一方，在通道中放入资金是天经地义的，但是对方却没有义务配合你放入资金；为了能获得remote_balance，你需要给对方一点好处才行，目前请求remote_balance的通道连接已经变成了一种服务，你需要`购买`这样的服务，以便在建立支付通道的时候能有remote_balance余额；

比如这个服务商：

https://yalls.org/about/

那么，购买这种服务，保证自己的支付通道中拥有remote_balance，有什么作用呢？为什么我们收款必须要依赖于它呢？

#### 进出容量(Inbound and Outbound Capacity)

现在，我们已经更清楚的了解了是什么决定了通道的容量以及local_balance和remote_balance 平衡更新的方式，接下来我们考虑一下，如果你是连接节点网络的一部分，会发生什么情况？

两个对等点不需要直接建立支付通道来互相支付。相反，他们可以通过路由节点中转支付。在路由的每一跳，都会发生对应通道内local_balance和remote_balance余额的更新。

假设你想要通过闪电网络出售一个披萨。你至少需要连接到一个闪电网络节点。你会仔细的选择人气尽可能高的节点，为你的顾客--SOPHIE和ANGELA提供收款服务；

这个时候的闪电网络拓扑是这样的：

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20191106/bg3.png)

>你打开了一个连接到LNTOP的支付通道，并在其中放入2个BTC，你的local_balance是2BTC，remote_balance为0BTC

现在，ANGELA想要买个披萨，并通过LNTOP支付给你。但是，你与LNTOP的支付通道里，remote_balance为0，所以LNTOP无法付款给你；

在某个特定时刻，你可以接收到的金额或者入站容量(Inbound Capacity)受到remote_balance的限制。你不能收到比你的邻接节点能发送给你的更多的金额。

类似的，你可以发送的金额，或者说出站容量(Outbound Capacity)也同样受到local_balance的限制。

当你用LNTOP打开一个通道时，你决定想要锁定多少比特币，即你的local_balance；类似的，如果LNTOP与你打开一个通道，他们将确定你的初始remote_balance。这具有重要意义。虽然选择local_balance允许你决定初始Outbound Capacity，但你无法控制remote_balance和Inbound Capacity。

如果你今天启动你的闪电节点，并简单的打开一个通道到你选择的另一个节点，你可能会惊奇的发现，自己没有Inbound Capacity，从而无法通过闪电网络接收付款；这对于一个商家来说绝对是大问题；

幸运的是，有好几种方法来获得Inboound Capacity，包括上面提到的，花钱给一些商家，让他们来为你提供一些remote_balance；

...TODO  方法待另一篇文章介绍


#### 这样就解决问题了吗？

嗯......，当然不会这么简单......在一个复杂的网络中，即使你在直接相连的通道中有足够的remote_balance，但你不能保证支付路径上的每一个节点都有充足的remote_balance； 让我们揭示网络中所有节点的local_balance和remote_balance，来更好的理解资金如何流动。

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20191106/bg4.png)

>如图: LNTOP是一个大的中转节点，与他相邻的每个节点都有LNTOP提供的remote_balance

这样你与LNTOP的支付通道中，你的remote_balance为3BTC， 而LNTOP与ANGELA的支付渠道中，LNTOP的remote_balance为2BTC，这样ANGELA最多能发送给你2BTC；

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20191106/bg5.gif)

>如图：ANGELA为你发送了1BTC


但是在这个网络中，SOPHIE甚至不能发送1BTC给你。如果你看一下SOPHIE和你之间的支付路线，就会发现LNTOP没有接收SOPHIE付款的能力；

对于收款，要求每个路由节点与你(接收方)之间都需要与前一个相邻的节点具有足够的Inbound Capacity；因此，即使你可能通过相邻节点获得了Inbound Capacity，但是整个支付路径上的某些节点可能并没有足够的Inbound Capacity；这样你仍然不能完成收款；

最致命的一点是，这种"显示所有节点的remote_balance和local_balance"的事情在闪电网络中是做不到的；作为网络的一个节点，我们只能知道其他支付通道的容量，而不知道它是如何在相连的两个节点之间分配资金的；

#### 谁会受影响

在闪电网络中，并不是所有的节点都有同等的需求。查看我们的示例，全网至少会有三种类型的节点：

##### 商人节点

商人节点主要需求是收款，因此，他需要Inbound Capacity，并且从客户到商人节点之间的支付路径上每一个节点，都要有足够的Inbound Capacity;

##### 用户节点

用户主要通过闪电网络发送资金，偶尔也会从朋友那里收到一些钱； 对于这些用户，他们的关键是要连接到的节点具有足够的资金能路由给商家；这些用户需要保有少量的remote_balance即可；


##### 路由节点

这些节点通过网络路由支付并为此收费。LNTOP就是这样的例子；

他们的工作是探测可用的支付路径。所以他们需要上游与终端用户的Inbound Capacity，以及下游与商家的Outbound Capacity；此外，它们的收费必须与市场上其他的公司竞争，他们还需要确保可靠性、充裕的流动性；这是一项艰难的工作，不是吗？

有很多攻击闪电网络的言论是：只有那些资金充裕的大公司才能有足够的精力和财力运行路由节点，根据马太效应，用户也会倾向于选择这些公司运营的节点服务；这样就会慢慢造成寡头垄断，最终比特币变成一个中心化的东西，变成一个大公司的玩物；

真的是这样的吗？


#### 结论

我们讨论了一个支付通道具有的特性，其通道容量、local_balance、remote_balance、Inbound Capacity, Outbound Capacity； 我们看到，闪电网络是一个丰富的生态，将来里面会有各种各样的角色参与其中；目前来看，如何注入足够Inbound Capacity，保持闪电网络有充裕的流动性似乎是个棘手问题；而且不少人攻击这最终会导致比特币运营中心化；

但我得说，这些批评者过于心急了；就像比特币诞生初期，很多传统的经济学家批评比特币的`通缩`特性一样；

为了解决这些问题，社区以一个惊人的创新速度不断提出解决方法，包括WIP、Lightning Loop、多路径余额合并平衡等等；我们也将会在后面的文章中一一介绍；

最后，数字货币世界还是处于蛮荒狂野时代，不是那么多事情都是理所当然的; 每个人的言论都需要批判吸收； 

乔帮主的训诫还是需要时时温习：饥渴求知，虚怀若愚(Stay Hungry, Stay Foolish)


#### 引用

https://blog.muun.com/the-inbound-capacity-problem-in-the-lightning-network/

https://github.com/lightningnetwork/lightning-rfc
