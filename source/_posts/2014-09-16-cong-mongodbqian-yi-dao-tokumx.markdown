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
     |<32 | 32-64| 64-128|....| < 4M| 4M-8M| --deleteList
     ---------------------------------------
      |       |      |     |     |      |
      |       |      |     |     |      |
     +-+     +-+    +-+   +-+   +-+    +-+
     +-+     +-+    +-+   +-+   +-+    +-+
             +-+    +-+   +-+   +-+    +-+
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

看看Tokumx的介绍:
"TokuMX is the MongoDB you know and love but built on top of Fractal Tree indexes from Tokutek."

从上层看，Tokumx 可以看成是Mongodb的克隆，仅仅是底层的存储方式用它们的Fractal Tree算法替换了mongodb的存储而已。

关于Fractal Tree，了解不多，从官方文档看，是对B-Tree的一个改进，通过对BTree的下级树叶保存子节点的缓冲区减少IO次数，另外可以用zlib等压缩算法存储数据

存储方式的改变，也改变了MongoDB默认用的MMap内存管理算法，Tokumx采用自定义的内存管理，直接表现就是占用内存可以手工控制了(事实上也推荐你指定一个内存占用值)，不像MongoDB那样对内存的占用贪得无厌。得益于Fractal Tree，因为I/O的减少，分形树索引不会要求索引必须小于内存。即使超过内存的限制，TokuMX依然可以维持很高的写入性能。

可以参考[这里](http://www.tokutek.com/2013/07/how-tokumx-gets-great-compression-for-mongodb/)
以及[这里](http://www.tokutek.com/2013/07/tokumx-fractal-treer-indexes-what-are-they/)
以及[这里](http://forms.tokutek.com/acton/attachment/6118/f-0039/1/-/-/-/-/lsm-vs-fractal.pdf)
以及[这里](http://www.tokutek.com/wp-content/uploads/2012/09/BenderKuszmaul-tutorial-xldb12.pdf)

Tokumx宣称了很多很好的[特性](http://www.tokutek.com/products/tokumx-for-mongodb/):

* Benefits for Developers
* 20x faster w/o tuning
* Transactions w/o tedious code
* Switch w/o changing your app
* Benefits for DevOps
* Use fewer servers; avoid upgrades
* 90% compression = less flash
* Scalability w/o losing data integrity

与Mongodg对比，官方宣称的限制有两个:

* 不支持全文索引
* 不支持GEO地理信息

我们看中的就是他的磁盘占用，对这两个限制不Care。

## Migrating data from MongoDB into TokuMX

怎样迁移，参考[官方Wiki](https://github.com/Tokutek/mongo/wiki)

## How about

#### 将Mongodb(2.4.9) 迁移到TokuMx (1.5.0)，插入的document多是4K左右，原Mongodb数据库达到TB级别，感性体验:

* 数据存储占用空间大幅下降，说只用原来的1/10并不夸大

* 每个collection及index都会存在单独的文件中,这样删除单表或索引后会立即释放占用的空间

* 同一个表，删除老数据，插入新数据，空间重复利用率>80%

* 写入速度没有20x的提升，但各种情况下，最差情况提升1倍是有的

* 读性能没有下降

#### 在我看来，与MongoDB相比，Tokumx的不足有以下几点:

* 稳定性; 因为采用了自定义的内存管理，不如MongoDB的MMap方式管理稳定，如果`cacheSize`设置不合适，而Tokumx的机器还有其他占用内存比较大的进程，会导致OOP，被系统杀掉的几率比较大。这要求我们设置`cacheSize`要斟酌一下。可以参考[这里](http://docs.tokutek.com/tokumx/tokumx-server-parameters.html); 顺便说一下，如果你的系统内存占用控制得当，是没有多大问题的。

* Tokumx的 Capped Collections性能比较渣，但是在我看来，存储方式的改变已经不需要这种方式了，所以这个不是问题。

* 我没有找到从Tokumx重新迁回MongoDB的现成工具，将来要迁回来，可能要手工写工具自己导数据

* Mongodb升级,新Feature的支持，还有商业化的问题。Tokumx的官网上的blog有人问了这个问题，问Tokumx有没有同MongoDB Merge的计划，开发者做了回答，很详尽。

    首先Tokumx的开发团队很小的，可能不会及时跟进Mongodb的新Feature移植

    第二两家公司有不同的商业化考量，另外代码的Merge有一定工作量，未来不太可能合并

    Tokumx只专注于存储性能的改进


#### 最后啰嗦一句，如果对当前的Mongodb Future没有很大的期待，并且像我一样为磁盘空间所困扰的同志们，大胆迁移到Tokumx吧。
