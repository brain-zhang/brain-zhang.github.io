---
layout: post
title: "从MongoDB迁移到TokuMx"
date: 2014-09-16 08:36:30 +0800
comments: true
categories: MongoDB TokuMx
---

## WHY:

原因无它，MongoDB的 BSON格式带来的磁盘空间消耗实在太严重了,将mongodb的数据库文件gzip一把，一般能到原大小的1/10。

### mongodb提出的解决办法有以下几个:

#### [定期repaire或Compact](http://docs.mongodb.org/manual/reference/method/db.repairDatabase/)，但是repaire带来的性能消耗实在太大，repaire或compact的时候插入性能基本上就是渣了，另外100G级别的数据库文件需要数小时才能压缩完毕。

#### 采用[Capped Collections](http://docs.mongodb.org/manual/core/capped-collections/)，这样在创建collections的时候可以指定数据库文件能占用的最大空间大小及单个document大小，当存储数据超过这个大小的时候会自动删除最老的数据，空出空间来。但这样做弊端就是你不知道会有多少数据被删掉，另外需要你对这个表插入的document大小心中有数。

#### 建立自己的清理机制，定期把无用的数据清理出去。这样虽然比Capped Collections可控制，但是对删除掉的磁盘空间利用率进一步下降了，很多时候，你删掉一半数据，能重新利用的空间可能也就10%。这是由MongoDB对于单个Document的空间分配机制决定的。

#### 最后一种方法就是合理规划，分库分表，然后在mongodb.conf里面设置选项:`directoryperdb = true`，这样mongo每个数据库都会建立一个文件夹,这样删除单库的时候数据文件就删干净了，空间自然清理出来了，这个选项我强烈推荐打开，即使你没有空间上的困扰，打开后也对数据库管理维护由不小的方便。当然指望这种办法删数据局限性就太大了。

详细说一下mongo对于删除空间的重新利用方法:

1.首先mongodb删除一个document的时候并不是物理上真正删除数据，而是维护一个deleteList链表数组，每次删除就在链表里面做一个标记。怎么表示这次删除的空间大小范围呢,如图示:

```
            ---------------------------------------
 deleteList |<32 | 32-64| 64-128|....| < 4M| 4M-8M|
            ---------------------------------------
             |       |      |     |     |      |
             |       |      |     |     |      |
            +-+     +-+     +-+   +-+   +-+    +-+
            +-+     +-+     +-+   +-+   +-+    +-+
                    +-+     +-+   +-+   +-+    +-+
                            +-+   +-+   +-+    +-+
```

2.对每一个被删除的docment计算其大小，然后插入到合适的链表中去，这样下次插入新数据的时候，先计算合适的空间大小，再在这个链表数组中找到合适的空闲空间指针地址，插入数据。如果没有合适的，再去开辟新空间。

3.这个链表数组每个大小区间是代码里写死的，可参见`namespace_detail.h`:
`int bucketSizes[] = { 32, 64, 128, 256, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000, 0x10000, 0x20000, 0x40000, 0x80000, 0x100000, 0x200000,0x400000, 0x800000};`


那么插入一条新的docement时，如何计算这个合适的空间分配大小就要斟酌了。mongo采取两种办法，选择哪一种可以在创建collection的时候指定:

1.Padding计算方式，这也是mongodb默认的方式。每次开辟空间的时候，采用公式 `实际大小*(1+paddingFactor)`，这个 paddingFactor一般比较小，在0.01-1之间，是根据插入document的大小自动变化的。可以在mongodb的shell里用`db.stats()`查看这个值。另外，repaire会把这个值置为1，compact操作可以手工指定这个值。

2.采用[usePowerOf2Size](http://docs.mongodb.org/manual/reference/command/collMod/)方式,这种方式和mongodb的磁盘空间分配比较相像，就是以2^2, 2^3, 2^4....大小增长，每次分配相近的空间大小

网上有人评价道:这两种方式各有优劣，padding方式会为文档开辟更合适的大小，而且paddingFactor比较小，一般为0.01-0.09，不会浪费空间，文档更新小的话也不会移动文档位置。但是当大量更新和删除的时候，这种方式重复利用空间的能力就比较小，因为在deleteList中，不太容易找到合适的已删除文档，而且一旦更新就会又移动位置，磁盘重复利用率低，增长快，碎片多。相比之下，usePowerOf2Size方式，Mongodb每次都会开辟比文档大的多的空间，使用空间变多，但是更新和删除的容错率就会比较高，因为在deleteList列表中更容易找到合适的删除文档（每个列表中的文档大小都是相同的固定的），更新的时候也不会大量移动位置，磁盘重复利用率高，增长慢。

#### 看起来这些策略很靠谱，但我实际用起来两种方法其实效果都不好，另外usePowerOf2Size的表现好一些，mongodb自2.6开始把这种分配方式变成默认的了。

#### 啰嗦了半天，我想说的就是, mongodb的存储受他的MMap内存管理所限，改来改去利用率没有本质提升。

## How to do?

### 升级Tokumx

#### 看看Tokumx的介绍:"TokuMX is the MongoDB you know and love but built on top of Fractal Tree indexes from Tokutek."
