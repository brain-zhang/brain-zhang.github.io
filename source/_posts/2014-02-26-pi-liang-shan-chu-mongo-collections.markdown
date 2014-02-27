---
layout: post
title: "批量删除mongo collections"
date: 2014-02-26 17:24:04 -0800
comments: true
categories: mongodb collections 批量删除 表
---

mongodb没有批量删除collecton的命令，平常建立了很多a1,a2,a3的表删除有些麻烦，写个小脚本方便些。

    mongorm.sh -d database -c a*

就很方便删除了。

{% gist 9242308 mongorm.sh %}

