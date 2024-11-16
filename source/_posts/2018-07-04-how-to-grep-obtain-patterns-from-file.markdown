---
layout: post
title: "how to grep obtain patterns from file"
date: 2018-07-04 18:06:55 +0800
comments: true
categories: tools
---

有一个100G的大文本文件 emailinfo.dict，包含邮箱及用户昵称; 格式为


```
hello@163.com,你是我的海
...

```


有一个用户名文件user.txt，格式为:


```
aaa
xxxx
....

```

我们希望找出emailinfo.dict中，以user.txt中用户名开头的所有内容。


首先将user.txt内容改为:


```
^aaa
^xxxx
....

```

然后执行:

    grep -G -f user.txt emailinfo.dict

这个`-G`参数又花了我半个小时去读文档，我都不知道第几次做这种事情了。人年纪大了果然只能靠笔记。
