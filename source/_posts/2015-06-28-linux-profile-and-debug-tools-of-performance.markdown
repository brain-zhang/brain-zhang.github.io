---
layout: post
title: "linux profile and debug  tools of performance"
date: 2015-06-28 08:52:15 +0000
comments: true
categories: tools
---

#### 用perf工具统计系统调用


```
perf top

```

或者统计一段时间内的调用


```
perf record -a -g -F 1000 sleep 30
perf report -g

```

#### 用strace 追踪某个进程的调用


```
strace -c ls

```

或者attach一个进程


```
strace -c -p pid

```

#### 查看磁盘调用


```
lsof -p pid

```

#### 磁盘负载


```
iostat -x 5 -m

```

整体负载统计


```
vmstat 5 

```
