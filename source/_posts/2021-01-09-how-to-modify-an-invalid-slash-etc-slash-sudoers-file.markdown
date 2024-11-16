---
layout: post
title: "How to modify an invalid '/etc/sudoers' file?"
date: 2021-01-09 16:16:31 +0800
comments: true
categories: tools
---

刚说小心驶得万年船，就想自己偷奸耍滑，手工裸编辑 `/etc/sudoers` 文件把sudo权限搞挂了...-_-

仔细瞅了瞅，少加了一个冒号，导致现在进退两难...

<!-- more -->

解决这个问题的标准方法是pkexec，参考：

https://askubuntu.com/questions/73864/how-to-modify-an-invalid-etc-sudoers-file

但是执行pkexec的时候又暴露了一个问题:

```
polkit-agent-helper-1: error response to PolicyKit daemon: GDBus.Error:org.freedesktop.PolicyKit1.Error.Failed: No session for cookie
==== AUTHENTICATION FAILED ===
Error executing command as another user: Not authorized
```

最后解决需要一点小技巧:

1. 在第一个shell种执行:`echo $$`，得到PID

2. 再开一个shell，再执行`pkttyagent --process PID`

3. 再回到第一个shell执行`pkexec visudo`

参考：

https://github.com/NixOS/nixpkgs/issues/18012


最后的教训是：人就是这样，要求别人头头是道，轮到自己偷奸耍滑；早用`visudo`还有这种事吗？

三省吾身，不说了，我得赶紧检查下自己其它耍滑头找方便留下的口子;
