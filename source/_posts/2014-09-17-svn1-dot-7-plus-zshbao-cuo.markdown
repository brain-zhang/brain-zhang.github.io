---
layout: post
title: "svn1.7+ Zsh报错"
date: 2014-09-17 08:40:14 +0800
comments: true
categories: SVN Zsh tools
---
更新svn(subversion)>1.7后 zsh 的svn自动完成会报错。

`_arguments:comparguments:312: invalid argument: [--cl]:arg:`

修改方法:

打开文件：/usr/share/zsh/4.3.11/functions/_subversion

找到35行左右

`${=${${${(M)${(f)"$(LC_ALL=C _call_program options svn help $cmd)"#(*Valid options:|(#e))}:#* :*}%% #:*}/ (arg|ARG)/:arg:}/(#b)-([[:alpha:]]) \[--([a-z-]##)\](:arg:)#/(--$match[2])-    $match[1]$match[3] (-$match[1])--$match[2]$match[3]}`
改为

`${=${${${(M)${(f)"$(LC_ALL=C _call_program options svn help $cmd)"#(*Valid options:|(#e))}:#* :*}%% #:*}/ (arg|ARG)/:arg:}/(#b)(-##)([[:alpha:]]##) \[--([a-z-]##)\](:arg:)#/(--$match[3])$match[1]$match[2]$match[4] ($match[1]$match[2])--$match[3]$match[4]}`

参考资料：
http://www.zsh.org/mla/workers/2011/msg01448.html
