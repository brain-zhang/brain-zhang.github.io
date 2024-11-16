---
layout: post
title: "how to sort a very very very big file"
date: 2018-05-03 07:21:50 +0800
comments: true
categories: tools
---

sort -uo 一个1T的文件，让最高配的google cloud instance (48 core/512G)崩溃了~~~，可惜了我的$30，白白跑了那么长时间~~~

网上搜索都是how to sort a big file，那我这个属于very very very big big big file了~~

不管是并行也好，管道也好，用了各种奇技淫巧就是敌不过人家 very very big~

不要跟我谈什么外排，归并，位图，bloom filter，redis hash去重，我就是不想折腾，最后只有分割手动外排搞定~~

### 把大象装进冰箱分为几步？

### 三步:


```
split -l 1000000000 huge-file small-chunk

for X in small-chunk*; do sort -u < $X > sorted-$X; done

sort -u -m sorted-small-chunk* > sorted-huge-file && rm -rf small-chunk* sorted-small-chunk*

```

### 小TIPS:

如果只要去重不要排序的话，尽量不要用 sort -u或者sort | uniq，这个是nLog(n)的效率，让人捉急。

可以利用awk的数组是内存hash表的特性，直接awk来做，前提是你内存够大，瞎估估需要十倍于数据的内存吧:


```
cat xxxxx zzz | awk '{ if (!seen[$0]++) { print $0; } }' > xxx_zzz.uniq.txt

```

### PS:

我后来又看了一下GNU Sort的实现描述，它说已经用了外排了，但是实际使用还是不给力，暂时迷惑中
