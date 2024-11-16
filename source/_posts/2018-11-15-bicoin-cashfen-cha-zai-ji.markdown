---
layout: post
title: "Bicoin Cash分叉在即"
date: 2018-11-15 15:08:32 +0800
comments: true
categories: blockchain
---

Bitcoin Cash 将于UNIX时间1542300000 (即北京时间2018年11月16日00：40)发生硬分叉;

分叉两派是比特大陆为首支持的[Bitcoin ABC](https://github.com/Bitcoin-ABC/bitcoin-abc)实现，以及Craig Steven Wright为首的[BItcoin SV](https://github.com/bitcoin-sv/bitcoin-sv)实现。

两派的恩恩怨怨政治斗争无心吐槽，咱也没有明确的倾向；但是作为码农咱要黑一黑；

<!-- more -->

[这里](https://github.com/bitcoin-sv/bitcoin-sv/commit/2ab7775797a5a37ab311ab9a067771e5c1bfe22a)是bitcoin SV 从Bitcoin ABC项目里面开始folk出来的修改；截至他们发布Bitcoin SV Beta1.0；最后提交的代码是[d9b12a23dbf0d2afc5f488fa077d762b302ba873](https://github.com/bitcoin-sv/bitcoin-sv/commit/d9b12a23dbf0d2afc5f488fa077d762b302ba873)


执行 `git diff 802629f d9b12a --stat` 瞄一眼:


```
699 files changed, 11634 insertions(+), 197401 deletions(-)

```

看起来改了不少，但是从头review一遍，他们从2018-08-22搞到现在，啥实质改动都没有，就开了几个操作码，改了几个测试；原本MAXBLOCKSIZE就变成可配置的了，他们不过是稍稍改了一下判断条件而已，改动最大的反而是README和release notes文件，最值得吐槽的就是这个提交：

https://github.com/bitcoin-sv/bitcoin-sv/commit/db8190ab5fb5262a6d3701017d733f106308fd0d

好吧，也不能无脑黑你，你还是修掉了一个比较重要的BUG的:

https://github.com/bitcoin-sv/bitcoin-sv/commit/a8ab90a375db85b192057aa11f56bfa0612d7e86

凭良心说，Bitcoin ABC的开发比不上Bitcoin Core的活跃，但起码Bitcoin Core有什么更新，人家能及时Merge过来啊！

曾经，像Bitcoin Gold之流，改个POW算法就出来割韭菜了，大家还愤愤不平；

Litecoin和Dogcoin还是改了改币数上限和出块时间的，这是在早期，咱们也忍了~~

如今Bitcoin SV的代码库让我见识了什么叫任性！

如果不赞成升级，原版代码运行就是；现在哥们，你们倒是放开了操作码！但是操作码执行实现的部分好好测试过了吗，对应的测试在哪里？就两天时间开放出来不怕出BUG吗？

同样的一个[重要BUG处理](https://bitcoincore.org/en/2018/09/20/notice/):

Bitcoin ABC的[重构+修正](https://github.com/Bitcoin-ABC/bitcoin-abc/commit/7e20479893089b2b80f81cc2e7e5712a2d4158ba)，BitcoinSV的[修正](https://github.com/bitcoin-sv/bitcoin-sv/commit/a8ab90a375db85b192057aa11f56bfa0612d7e86); 态度啊~~

我觉得数字货币这个场子没啥正义公理权威可言，就是中本聪重现人间，相信说话也没多大分量了；但是代码质量是没办法靠嘴炮提升的；长久来看，占据市场还是要靠产品质量啊。

但是不管怎么样，接下来的战争是一场明刀明枪的较量，没有重放保护，双方都是投入真金白银维护自己的立场，这比空气币收割韭菜实诚多了；

比特币这个社会实验已然十年，终于出现了白皮书所描写的第一场大规模算力战争，值得期待啊。
