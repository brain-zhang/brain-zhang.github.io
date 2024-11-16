---
layout: post
title: "how to improve performance your cmd by parallel"
date: 2018-05-06 09:32:03 +0800
comments: true
categories: tools
---

有很多时候，处理一个大文件，常规命令并不能很好的利用多核

<!-- more -->

例如，一个1T的文本，百亿条数据，我想要:


```
wc -l test.txt

```

或者


```
fgrep xxxx test.txt

```

一般机器就会自觉进入`一核有难，其它核点赞`的看戏模式。

我花钱配了这么多核，加了这么多内存，不是让大家来看戏的。于是祭出`parallel`~

## 原理

parallel 是一个perl脚本，通过分割输入，并行处理的方式来加速执行命令。

例如:


```
wc -l test.txt

```

简单想想就是用个for循环split文件，挨个wc，然后相加。parallel就是自动帮你把这类事情做掉而已。大道不过两三行，所谓外部排序，Map-Reduce莫不如是。

## 安装 (ubuntu 16.04LTS)


```
 apt-get install parallel

```


## 示例

#### 最快的办法计算一个大文件的行数


```
cat bigfile.txt | parallel --no-notice --pipe wc -l | awk '{s+=$1} END {print s}'

```

非常的巧妙，先使用parallel命令‘mapping’出大量的wc -l调用，形成子计算，最后通过管道发送给awk进行汇总


#### SED, 想在一个巨大的文件里使用sed命令做大量的替换操作吗？

常规做法：

```
sed s^old^new^g bigfile.txt

```

现在你可以：

```
cat bigfile.txt | parallel --no-notice --pipe sed s^old^new^g

```

#### GREP 一个非常大的文本文件

以前你可能会这样：


```
grep pattern bigfile.txt

```

现在你可以这样：

```
cat bigfile.txt | parallel --no-notice --pipe grep 'pattern'

```

或者这样：

```
cat bigfile.txt | parallel --no-notice --block 10M --pipe grep 'pattern'

```

这第二种用法使用了 –block 10M参数，这是说每个内核处理1千万行——你可以用这个参数来调整每个CUP内核处理多少行数据。

#### 压缩一个非常大的文件

bzip2是比gzip更好的压缩工具，但它很慢！别折腾了，我们有办法解决这问题。

以前的做法：

```
cat bigfile.bin | bzip2 --best > compressedfile.bz2

```

现在这样：

```
cat bigfile.bin | parallel --no-notice --pipe --recend '' -k bzip2 --best > compressedfile.bz2

```

## 扩展

作为一个Python党，经常写一些`用过即弃`的边角料脚本

比如最近要把一个1T的文件汉字全部转换为拼音，初版当然是这样的:

#### 版本1


```
with io.open(sys.argv[1], encoding='utf-8') as fp:
    for line in fp:
        print(lazy_pinyin(line))

```

lazy_pinyin的效率奇慢无比，这回陷入了一核有难，其它核+内存+磁盘全部看戏模式


作为一个初级合格的Python开发人员，你当然说要用process，于是我们有了第二版:

#### 版本2


```
from multiprocessing import Pool
pool = Pool(16)
with io.open(sys.argv[1], encoding='utf-8') as fp:
    pool.map(lazy_pinyin, fp, 16)
    pool.close()
    pool.join()

```

嗯，很好，16个核都跑起来了；但是你有很快尴尬的发现，map把文件一把load进来，内存有难了


#### ~~~~

作为一个初级合格的Python开发人员，你当然说不要一把读进来，要用chunk_read，一次读一块，或者更高级一点，直接用mmap映射进内存巴拉巴拉


#### 少年，这还是那个边角料脚本吗，你已经在它上面操心一个小时了，还能不能愉快的玩耍了

让 parallel来拯救你

#### 版本3


```
import fileinput

if __name__ == '__main__':
    for line in fileinput.input():
        lazy_pinyin(line)

```

然后执行:


```
cat bigfile.txt| parallel --no-notice --pipe python pinyinconv.py > pinyin.result

```

享受所有CPU满负荷运载的工头压榨工人的快感吧


## 一些扩展

* 为啥所有的parallel都带有一个奇怪的--no-notice?

嗯，虽然这个作者非常非常好，但是他总是在命令前面输出一些捐助提示；当然我并不是讨厌这种做法，但看多了总有些疲劳，你懂的~~


* 我有一些参数想传给程序，怎么办？


```
 seq 3|parallel --no-notice -q echo seq{}

```

* 这个命令很好，但是语法好像啰嗦了一些，还有其它的替代命令吗？

嗯~ o(*￣▽￣*)o，还是有的，xargs有个-n参数，类似的效果，不过功能弱化很多，基本上是鸡肋


## 参考:

#### 手册:

https://www.gnu.org/software/parallel/parallel_tutorial.html

#### 资料:

http://www.freeoa.net/osuport/sysadmin/use-gnu-parallel-multi-core-speed-up-cmd_2343.html

我的博客即将搬运同步至腾讯云+社区，邀请大家一同入驻：https://cloud.tencent.com/developer/support-plan?invite_code=1bnzu1pmog27t
