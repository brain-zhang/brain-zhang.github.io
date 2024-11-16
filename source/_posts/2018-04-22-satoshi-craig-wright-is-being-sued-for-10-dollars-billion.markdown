---
layout: post
title: "Satoshi Craig Wright Is Being Sued for $10 Billion"
date: 2018-04-22 19:31:24 +0800
comments: true
categories: blockchain
---

啥也不说了，涉及百亿美元的案子，估计在人类历史上都能排前排了。

而且作为Bitcoin粉，我估计这个案子有可能在历史上空前绝后。涉及悬疑，天才，欺诈，巨额金钱，先知等等元素~~

留名之。


https://www.coindesk.com/satoshi-craig-wright-sued-10-billion/

另外我对这篇[文章](http://brain-zhang.github.io/blog/2018/04/22/satoshi-craig-wright-is-being-sued-for-10-dollars-billion/)用press.one进行了[签名:](https://press.one/file/v?s=60db2f3ea40a25d28781c900af248523eb3c17024ce3ca18a42433035aff55524e4b2df76cfcef1466d38c4e23e4ab770d42359835b66d159cd5dd5099e0be260&h=a93f5a68189ff4a9b14d9e592c4dd0a8a1b649d0191b58740d93ce10c0d055ec&a=7e32e3deba87efcd35bc6d1ab355d85c50aa60bd&v=2&f=P1)

<!-- more -->

#### PS:附一下之前的总结

2016-05更新:

=========================

参考http://8btc.com的文章:

为什么说这个中本聪是假的



Craig Wright 又在声明他是”中本聪”了.

“中本聪”给出的签名是：


```
    MEUCIQDBKn1Uly8m0UyzETObUSL4wYdBfd4ejvtoQfVcNCIK4AIgZmMsXNQWHvo6KDd2Tu6euEl13VTC3ihl6XUlhcU+fM4=

```

我们先对信息串进行base64解码，再转换成hex是：


```
    3045022100c12a7d54972f26d14cb311339b5122f8c187417dde1e8efb6841f55c34220ae0022066632c5cd4161efa3a2837764eee9eb84975dd54c2de2865e9752585c53e7cce

```

很遗憾，我们可以在交易ID：



```
    828ef3b079f9c23829c56fe86e85b4a69d9e06e5b54ea597eef5fb3ffef509fe

```

中找出这个签名。可通过：

https://blockchain.info/tx/828ef3b079f9c23829c56fe86e85b4a69d9e06e5b54ea597eef5fb3ffef509fe?format=hex

找到十六进制串的交易内容

然后搜索一下hex样子的签名，遗憾地发现，能在这个交易中找到这个签名。





但是令人疑惑的是GAVIN ANDRESEN为这位”中本聪”背书:

http://gavinandresen.ninja/satoshi


Gavin不是一个无的放矢的人,他肯定是见到了更多的证据.


但是Craig Wright 又不对其他给定的文本签名来证明自己是中本聪,反而老是用这种神神遭遭的签名来忽悠大家……


卫平布莱恩特老师说,这球有意思啊…….


最后, 如果Craig Wright这个人是为了某种目的假冒的话,只能说他真是煞费苦心啊. 我不认为一个签名造假如此low的家伙能有这种能力.


但是他的一些行为如果算恶作剧的话,又未免太高段了,参考这里:

https://www.zhihu.com/question/22199390/answer/76083139


不负责任的YY一下, Craig Wright肯定和真正的中本聪有某种关系,他在bitcoin诞生之初就了解参与过.



他不是bitcoin的发明者,因为种种迹象表明,他的技术能力实在太low了.



真正的中本聪可能是他的那个朋友:David Kleiman, 但他已经死了.



呵呵, 绝佳的侦探小说体裁啊.



2017-12-24更新

================

我在比特币开发论坛的早期帖子上发现了一个线索，在bitcoin release 0.1版本的时候，satoshi曾经自称自己:


    "The design supports a tremendous variety of possible transaction types that I designed years ago.  Escrow transactions, bonded contracts, third party arbitration, multi-party signature, etc.  If Bitcoin catches on in a big way, these are things we'll want to explore in the future, but they all had to be designed at the beginning to make sure they would be possible later."


这代表satoshi早期的职业生涯和金融、保险以及法务方面联系很紧密，同时看他的代码风格是老派C++的写法，有MS的味道 ：），然后看看 David Kleiman的个人主页，浮想联翩啊。



2018-04-22更新

==================

Craig Wright的案宗已经出来了:


https://www.coindesk.com/satoshi-craig-wright-sued-10-billion/

我觉得基本上可以确定猜测是对的，但是除了Craig Wright本人，真相的细节可能永远不会有人知道了。

现在最大的疑问就是100w币的私钥是谁控制着？
