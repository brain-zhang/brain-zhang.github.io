---
layout: post
title: "How to sort by length of string followed by alphabetical order"
date: 2020-08-17 08:34:52 +0800
comments: true
categories: tools
---

shell中，多行文本，先按照字母长度排序，相同长度再按照字母序排列；

做了很多次，隔几天就忘，让人绝望：

```
cat /tmp/xxx.txt|sort -u | awk '{print length($0), $0}'  | sort -k2,2n -k1,1n -k3,3 |cut -d" " -f2-|less
```
