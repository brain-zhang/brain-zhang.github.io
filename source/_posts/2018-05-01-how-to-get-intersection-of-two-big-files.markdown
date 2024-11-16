---
layout: post
title: "how to get Intersection of two big files"
date: 2018-05-01 22:18:33 +0800
comments: true
categories: tools
---

两个大文件，a.txt和b.txt两个文件的数据都是逐行呈现的， 如何求他们的交集、并集和差集。

用sort+uniq直接搞定:

## 交集

```
$ sort a.txt | uniq > aa.txt
$ sort b.txt | uniq > bb.txt
$ cat aa.txt bb.txt | sort | uniq -d

```

## 并集


```
cat a.txt b.txt | sort | uniq

```

## 差集


```
$ sort a.txt | uniq > aa.txt
$ sort b.txt | uniq > bb.txt
$ cat aa.txt bb.txt bb.txt | sort | uniq -u

```

* 在开搞 bloom filter或者bitmap 或者grep -f之前可以先组合工具来一个
