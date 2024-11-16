---
layout: post
title: "how to parallel all cmds for linux"
date: 2018-05-01 13:07:20 +0800
comments: true
categories: tools
---

grep 一个100GB的文件总是很有压力，怎么才能提速呢?

### 瞎优化


```
LC_ALL=C fgrep -A 5 -B 5 'xxxxx.password' allpassseed.txt

```

* `LC_ALL=C`比`LC_ALL=UTF-8`要块

* 不需要正则的话，用fgrep可以提速


### 不过这样优化总是治标不治本，下面隆重推出linux 里面parallel all cmds的perl工具


```
cat allpassseed.txt |parallel  --pipe  --no-notice grep -f xxxxx.password

```

使用parallel ，和不使用parallel直接grep。结果显而易见，相差 20 倍。这比用啥 ack，ag优化效果明显多了


### xargs也有一个-n的多核选项，可以作为备用


```
$ time echo {1..5} |xargs -n 1  sleep

real    0m15.005s
user    0m0.000s
sys 0m0.000s

```

这一条xargs把每个echo的数作为参数传给sleep ，所以一共sleep了 1+2+3+4+5=15秒。

如果使用 -P 参数分给5个核，每个核各sleep 1,2,3,4,5秒，所以执行完之后总共sleep的5秒。


```
$ time echo {1..5} |xargs -n 1 -P 5 sleep

real    0m5.003s
user    0m0.000s
sys 0m0.000s

```

* 引自:

https://www.jianshu.com/p/c5a2369fa613
