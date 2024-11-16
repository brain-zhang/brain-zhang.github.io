---
layout: post
title: "the minimum fee of bitcoin transaction"
date: 2018-09-11 15:13:35 +0800
comments: true
categories: blockchain bitcoin
---

昨天看到地球人都知道的1号地址转了[0.00000555个币进来](https://btc.com/b9a6f0b287646c30bdafa08cc997d7af93ca20eb7b2d09084ddf7a7a075394b2)，也不知道是谁在做测试，恶作剧心起，遂想要转掉这点娱乐币。

默认Bitcoin Core 0.15之后的客户端貌似都不能调节transaction fee大小了，老实说，自从Segwit升级完毕之后，我很少用core钱包了。这次没办法，为了构造一笔最小手续费用的交易，采取如下动作:

<!-- more -->

1.先看一下vout和txid:


```
bitcoin-cli listunspent 0 9999999 "[\"12AKRNHpFhDSBDD9rSn74VAzZSL3774PxQ\"]"

```
输出里面找到 `12AKRNHpFhDSBDD9rSn74VAzZSL3774PxQ`的vout为0， txid是`b9a6f0b287646c30bdafa08cc997d7af93ca20eb7b2d09084ddf7a7a075394b2`

2.创建转账交易


```
bitcoin-cli createrawtransaction "[{\"txid\":\"b9a6f0b287646c30bdafa08cc997d7af93ca20eb7b2d09084ddf7a7a075394b2\",\"vout\":0}]" "{\"1HB1Efu8RkEpxzTHYd1E7NgdimL1ddDhkR\":0.0000055}"

```

得到十六进制输出


```
0200000001b29453077a7adf4d08092d7beb20ca93afd797c98ca0afbd306c6487b2f0a6b90000000000ffffffff0126020000000000001976a914b1665e71006dbfbabb69cbcdc5717b11abdb89e888ac00000000

```

3.签名之


```
bitcoin-cli signrawtransaction  "0200000001b29453077a7adf4d08092d7beb20ca93afd797c98ca0afbd306c6487b2f0a6b90000000000ffffffff0126020000000000001976a914b1665e71006dbfbabb69cbcdc5717b11abdb89e888ac00000000"

```

得到十六进制输出


```
{
  "hex": "0200000001b29453077a7adf4d08092d7beb20ca93afd797c98ca0afbd306c6487b2f0a6b9000000008a47304402202a51aa8eb0593a4b48880712c3ee70b7d6ca74ed313ef93e9c92489616587a2c022048c87fde75761e2a9cc9fef7dc8d0d9961ef1df89e22f88e5e3902567ec956f8014104fdf4907810a9f5d9462a1ae09feee5ab205d32798b0ffcc379442021f84c5bbfc891eb16b0faef4bef99ba6d522fb85470a20df730808e583778aa35c7af98f5ffffffff0126020000000000001976a914b1665e71006dbfbabb69cbcdc5717b11abdb89e888ac00000000",
  "complete": true
}

```

4.激动人心的时刻来了，广播之:


```
bitcoin-cli sendrawtransaction  "0200000001b29453077a7adf4d08092d7beb20ca93afd797c98ca0afbd306c6487b2f0a6b9000000008a47304402202a51aa8eb0593a4b48880712c3ee70b7d6ca74ed313ef93e9c92489616587a2c022048c87fde75761e2a9cc9fef7dc8d0d9961ef1df89e22f88e5e3902567ec956f8014104fdf4907810a9f5d9462a1ae09feee5ab205d32798b0ffcc379442021f84c5bbfc891eb16b0faef4bef99ba6d522fb85470a20df730808e583778aa35c7af98f5ffffffff0126020000000000001976a914b1665e71006dbfbabb69cbcdc5717b11abdb89e888ac00000000"

```

然后得到报错:


```
error message:
66: min relay fee not met

```

喵喵喵，怎么回事，我记得2016年的时候还是允许0.00000001的手续费的，比如下面这笔交易:

https://blockchain.info/tx/d36a18d1fa4c6ccc4b90ab8a13dd3e55b396ac07bf7fbbee281c1025da2b86fc

5.没办法，我只能在createrawtransaction的时候手工指定手续费为0.000001，心痛啊，手续费是转账金额的20%~

然后又得到了这个错:


```
mempool min fee not met

```

怒了，又去翻了一下代码，还是由mempoolminfee 决定的啊，执行:


```
bitcoin-cli getmempoolinfo

```

现在是够的啊，搞不明白了；不行，再等别人就转走了，得争分夺秒啊2333

6.只能去找几个大矿池在线广播了，我无奈的先后使用了:

https://btc.com/tools/tx/publish

https://www.blockchain.com/btc/pushtx

https://live.blockcypher.com/btc/pushtx/

统统失败，悲剧了；还测试出blockcypher有个500，它的后台没处理好，直接就挂掉了；btc.com是个鬼精灵，把所有的异常一把抓，就不告诉你出了啥错；值得表扬的是blockchain.info，完美显示了bitcoin core抛出的错误，嗯嗯嗯，记住，以后可以用极小值的手续费广播来测试这几个网站的后台bitcoind 实现版本，不要干坏事哦~~


7.万般无奈之下我将手续费用继续提高为0.000002，然后得到下面的报错:


```
dust transaction

```

一顿google之下发现0.15版本以后，bitcoin core的[dust判定标准是546 satoshins](https://bitcoin.stackexchange.com/questions/10986/what-is-meant-by-bitcoin-dust)，这笔交易的金额正好处于这么一个微妙的位置。

8.一通操作之后，发现这笔钱是无论如何不能立即拿出来了；于是写个脚本暴力广播之，总有mempool size下来的时候吧，我幻想着，说不定能中奖呢23333


#### 结局

昨晚有个土豪加上另外一个vout提走了，额，为了提0.00000555BTC，土豪动用了88BTC的vout作为陪练，并留下了0.00000400(高达90%) 的矿工费，交易记录在此:

https://btc.com/d6d59802eb987fe96b9e827c07a1acff5e80ba5e9dae3f6f56f9ea427d98e585

土豪，是在下输了。

这件事情挺有意思的，我相信还有很多自动机器人在hunter这几个大众抽奖地址，为了不到1分钱，真是`一通操作猛如虎，回头一看啥没有`。而且中间还有一笔流入，我放过了；作为傻逼的记录，我老老实实记一下。

现在minimum fee的行情是0.00001/KB，下次我得记好了，方便抽奖。

