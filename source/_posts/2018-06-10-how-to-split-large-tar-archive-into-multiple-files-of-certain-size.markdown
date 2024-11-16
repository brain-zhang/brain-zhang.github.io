---
layout: post
title: "How to Split Large ‘tar’ Archive into Multiple Files of Certain Size"
date: 2018-06-10 21:50:43 +0800
comments: true
categories: tools
---

有时候需要压缩文件的时候同时分割一下:


```
tar czvf - -C /mnt/g/dict/ weakpass_merge.dict |split -b 10000M - "weakpass.part.tar.gz."

```


还原:


```
cat weakpass.part.tar.gz.*|tar zxvf

```
