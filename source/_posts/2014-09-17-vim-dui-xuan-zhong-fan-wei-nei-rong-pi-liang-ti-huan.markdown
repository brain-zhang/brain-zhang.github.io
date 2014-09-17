---
layout: post
title: "Vim 对选中范围内容批量替换"
date: 2014-09-17 08:31:22 +0800
comments: true
categories: Vim
---
vim可以很方便的用 %s/src/dst/g 批量替换。

但是我想对ctrl+v 块选择的内容做批量替换就麻烦一点了，每次都得打一串很长很长的脚本命令。

发现的一个插件做这个事,vis:

https://github.com/vim-scripts/vis

支持两个命令模式:B 和 S

`B` 在选定区域内执行命令

ctrl+v选中内容后，使用`:B cmd`，此时命令栏的状态应该是`:'<,'>B cmd`这样。

例如替换内容, `ctrl-v`  `:B s/pattern/becomes/`

执行外部命令，`ctrl-v`  `:B !sort`

`S` 在选定区域内查找内容

`ctrl+v`选中内容后，使用`:S pattern`，此时命令栏的状态应该是`:'<,'>S pattern`这样。

解脱了….

记一下免得又忘掉。
