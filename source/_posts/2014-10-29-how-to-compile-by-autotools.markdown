---
layout: post
title: "how to compile by autotools"
date: 2014-10-29 12:12:30 +0800
comments: true
categories: gcc autotools tools
---

虽然因为llvm的出现，开源工具链又开始慢慢进化了，但是很多项目还是需要autotools自动gen configure的，但是我每次命令都记不全，还是记一下吧


```
#!/bin/bash

echo "Running aclocal..."
aclocal || exit 1
echo "Running autoheader..."
autoheader || exit 1
echo "Running autoconf..."
autoconf || exit 1
echo "Running automake..."
automake --add-missing --copy || exit 1
echo "Finished."

```
