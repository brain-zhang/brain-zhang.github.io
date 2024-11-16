---
layout: post
title: "xargs sh -c skipping the first argument"
date: 2020-08-12 16:46:27 +0800
comments: true
categories: tools
---

其实这个问题已经见过很多次了，但是知其然不知其所以然；今天偶尔在stackoverflow上看到了，记录一下；


#### shell中的arg1, arg2...

在bash shell中，`$1`, `$2`代表arg1, arg2，比如

```
# echo hello world|xargs echo $1 $2

hello world
```

<!-- more -->

`$0` 代表执行环境，如果是一个执行脚本的话，`$0` 代表其脚本名；比如下面这个脚本hello.sh:

```
#!/bin/bash

echo $0
echo $1
echo $2
```

执行:

```
# ./hello.sh arg1 arg2

```
会输出

```
./hello.sh
arg1
arg2
```

#### xargs 调用sh -c 中的arg

但是使用`xargs sh -c`时会出现一个比较疑惑的情况，比如执行:

```
# echo hello world|xargs sh -c 'echo $1 $2'

world
```

此时`$1`代表world，`$2`已经没有值了；而执行

```
# echo hello world|xargs sh -c 'echo $0 $1'

hello world
```

反而得到了正确结果；

#### why

之前我一直认为`xargs sh -c`调用的时候吃掉了`$0`，不求甚解；偶尔读了一下sh的手册才发现玄机:

> From the documentation for the -c option:

> Read commands from the command_string operand. Set the value of special parameter 0 (see Special Parameters) from the value of the command_name operand and the positional parameters ($1, $2, and so on) in sequence from the remaining argument operands.

就是说在上面这条命令中，其实是没有找到要执行的命令，或者说要执行的命令为空，而hello world作为`$1`, `$2`传给一个空命令了；

后面追加一个dummy的命令会看的更清楚:


```
# echo hello world|xargs sh -c 'echo $1 $2' _

hello world
```

后面我加了一条下划线作为xargs的dummy command，这样`$1`, `$2`就恢复正常了；

#### 总结

虽然这是一个啥用也没有的Magic Topic，但是搞明白之后还是挺有意思的，娱乐用；

另外隐隐约约觉得这里面隐含着一些安全方面的问题，暂时只是一种感觉，将来需要留意有没有这方面的hack手段;


#### 引用

https://stackoverflow.com/questions/41043163/xargs-sh-c-skipping-the-first-argument
