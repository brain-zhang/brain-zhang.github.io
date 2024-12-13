---
layout: post
title: "用watch命令高亮输出的不同"
date: 2024-12-13 12:07:14 +0800
comments: true
categories: tools
---

```
watch -d date
```

`-d` 参数会将两次输出之间的差异高亮显示；

我赶紧又 `man` 了一下 `watch` 命令的选项，又得到了几个对我有用的功能:

`-b` 参数可以在程序异常退出的时候响铃

`-g` 参数可以在程序输出发生变化时退出watch命令

还有我最常用的 `-n`参数，控制watch的间隔


Linux上面很多小命令，是从上世纪70年代的上古UNIX时期一路经过血战竞争才能留到现在的，论设计肯定是精益求精了；
