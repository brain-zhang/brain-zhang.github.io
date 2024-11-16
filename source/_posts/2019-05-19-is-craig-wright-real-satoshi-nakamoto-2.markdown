---
layout: post
title: "Is Craig Wright Real Satoshi Nakamoto-2"
date: 2019-05-19 10:15:27 +0800
comments: true
categories: blockchain
---

之前我们写过两篇文章来八卦所谓的`澳本聪`的故事:

[Is Craig Wright Real Satoshi Nakamoto?](https://brain-zhang.github.io/blog/2016/05/02/is-craig-wright-real-satoshi-nakamoto/)

[Satoshi Craig Wright Is Being Sued for $10 Billion](https://brain-zhang.github.io/blog/2018/04/22/satoshi-craig-wright-is-being-sued-for-10-dollars-billion/)

PS: 学术界普遍怀疑其实 [Nick Szabo](https://www.blogger.com/profile/16820399856274245684)才是中本聪；偶也50%认同；

最近这个故事又有了新的神转折，实在是太有意思了。现实生活中，有时候我觉得八卦那些明星太无聊了，但是在cyberspace中，偶的八卦之心熊熊燃烧，都让我有点体会那些狗崽队的心情了~~~

<!-- more -->

之前我们做出的推论是:

> Craig Wright肯定和真正的中本聪有某种关系,他在bitcoin诞生之初就了解参与过.

> 他不是bitcoin的发明者,因为种种迹象表明,他的技术能力实在太low了.

> 真正的中本聪可能是他的那个朋友:David Kleiman, 但他已经死了.

之后的剧情就是 David Kleiman的亲属起诉Craig Wright，声称他窃取了 本该属于  David Kleiman 的100w bitcoin；其起诉文书中公布了大量的由 Craig Wright声称其属于他和Kleiman成立的名为`郁金香信托`基金的bitcoin address;

参见[这里](https://www.coindesk.com/satoshi-craig-wright-sued-10-billion)， [这里](https://www.reddit.com/r/Bitcoin/comments/80e2l9/10_billion_lawsuit_filed_against_craig_wright/)

很快，就有人对其文件中所列出的地址做了详细分析；认为其地址根本就是 Craig Wright 随便在bitcoin blockchain找的大额未动币的地址，根本和他没关系；当然，跟David Kleiman也没关系；两拨人马完全是在为`一笔完全不存在的财富`纠缠不清；

甚至，这些地址中，有一个地址是Mtgox小偷的地址！ 如果这份文件是真的，那么岂不是说Craig Wright自己承认是Mtgox的窃贼！

参考[这里](https://blog.wizsec.jp/2018/02/kleiman-v-craig-wright-bitcoins.html)；

地址分析：


```
12tLs9c9RsALt4ockxa1hB4iTCTSmxj2me: unknown
1933phfhK3ZgFQNLGSDXvqCn32k2buXY8a: MtGox user
1FeexV6bAHb8ybZjqQMjJrcCrHGW9sb6uF: first major MtGox theft
1f1miYFQWTzdLiCBxtHHnNiW7WAWPUccr: unknown
1MHdm5XZMrfoZFoUktEaGhYevmdiXoc4x4: unknown (early miner)
18JPragfuDVHWWG8ABQ15cghJFetnXUjBD: MtGox user
1LXc28hWx1t8np5sCAb2EaNFqPwqJCuERD: unknown
1FpqQnKQCgDkJFMC94JL8FpRyHTZ3uRVZ1: unknown (early miner)
1F34duy2eeMz5mSrvFepVzy7Y1rBsnAyWC: from MyBitcoin.com
1JtpgqCf3SSeCeYWEDJjkfYFH7Ruhy4Vp1: unknown (early miner)
18k9tin39LKegFzHe8rxSgvJXDpuMriGJq: unknown
1HtTw9zR9wWFfgV8Jy8MqsaeVi7ZXrjdq6: part of a long chain of transactions that send minor amounts into a BTC-e deposit address
18pn4NQ7NgsJjeuFjazeTdVRnsmfw5ofTz: unknown
12fZ2HxkLjG9zn1u44XYsFFYKHM4A2zCea: MtGox user
12tkqA9xSoowkzoERHMWNKsTey55YEBqkv: unknown (early miner)
16Ls6azc76ixc9Ny7AB5ZPPq6oiEL9XwXy: MtGox cold storage
12HddUDLhRP2F8JjpKYeKaDxxt5wUvx5nq: MtGox cold storage
1P3S1grZYmcqYDuaEDVDYobJ5Fx85E9fE9: MtGox cold storage
1MyGwFAJjVtB5rGJa32M6Yh46cGirUta1K: MtGox cold storage
145YHsQU7HMzkRnD5SBSuFAzQgCYnAnLkN: unknown (early miner)
16TPVCpvtJ6FkV5xNKBp35aMo4BWFGxiEY: unknown
1KbrSKrT3GeEruTuuYYUSQ35JwKbrAWJYm: unknown
1FLFnbN7m5psLfvLEwYfRUUjJ34YkmV3dM: donation recipient
1A6SDef1TJAM8Saw2SqmqFGhkWR1y3qMx2: MtGox deposit address
16cou7Ht6WjTzuFyDBnht9hmvXytg6XdVT: MtGox user
12ib7dApVFvg82TXKycWBNpN8kFyiAN1dr: unknown (early miner)

```

呵呵，就在前几天，有人用`16cou7Ht6WjTzuFyDBnht9hmvXytg6XdVT`这个地址的私钥，签名发布了一段消息：


```
Address 16cou7Ht6WjTzuFyDBnht9hmvXytg6XdVT does not belong to Satoshi or to Craig Wright.
Craig is a liar and a fraud.

```

这段消息的签名是:


```
G39S6i4XsfQnixN5ePMjVPboWvGXdnW8xFFAXiwEriZFCclflbD7umP58u3Sl+dvvXC5BxBrRNkTMNf92O1UIXw=

```
这段签名可以用Electrum的工具验证无误；懂一点技术的人自然明白这意味这什么。

那么问题又来了，为什么这位英雄好汉不在去年早点揭露这件事呢？

也许是法律文件太过冗长，没什么人仔细去研究，更不用说作为一个早期的Bitcoiner Hodler了；

嗯，这个理由很合理；但是~~~~

马上又有人挖出了更大的瓜，这个地址是Roger Ver控制的；

https://www.reddit.com/r/btc/comments/bpdac1/address_16cou7ht6wjtzufydbnht9hmvxytg6xdvt_does/

https://www.reddit.com/r/btc/comments/7cehzo/roger_ver_45000_bitcoin_moved_to_exchange/

之前在Bitcoin扩容之争的时候，Roger Ver还用这个地址投过票；

而Roger Ver与Craig Wright的关系也是百转千回~~

* Craig Wright初次宣布自己是Satoshi, Roger Ver 坚持黑；

* BCH分叉， Craig Wright投入BCH阵营， Roger Ver 粉；

* BSV分叉， Craig Wright自立门户， Roger Ver 出来掀桌了；

真相目前不得而知，但是可以确认的有一件事情：

像所有的区块链项目以及牵涉其中的人一样， Craig Wright, Roger Ver， 所谓的`郁金香信托`， Mtgox， BCH, BSV 等等，他们之间充斥着谎言中的谎言，是迷宫中的迷宫；

我觉得所谓的`区块链行业`有个铁律：

#### 有区块链的地方一定会有骗子。

这再一次提醒我们，在区块链世界中，任何人都不值得信任，唯一可以依靠的只有自己的知识和判断：

## Don't Trust. Verify.
