---
layout: post
title: "Paste fails when using bracketed-paste-magic on zsh5.1.1"
date: 2019-09-13 10:50:31 +0800
comments: true
categories: tools
---

突然碰到了zsh5.1.1的一个bug，粘贴中文的时候会把shell freeze；

不知道是不是on-my-zsh升级的时候搞坏的，一通搜索发现了这个:

https://github.com/zsh-users/zsh-autosuggestions/issues/102

没有升级zsh，我直接到配置文件里把那段自动转义的功能注释掉了，嗯，简单粗暴~~~这东西我也不想天天升级；

```
~/.oh-my-zsh/lib/misc.zsh
```
