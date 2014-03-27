---
layout: post
title: "vim 对选中范围内容批量替换"
date: 2014-03-27 09:14:12 +0800
comments: true
categories: vim vis 替换
---

vim可以很方便的用 `%s/src/dst/g` 批量替换。

但是我想对ctrl+v 块选择的内容做批量替换就麻烦一点了，每次都得打一串很长很长的脚本命令。

发现的一个插件做这个事,vis:

https://github.com/vim-scripts/vis


解脱了....

记一下免得又忘掉。
