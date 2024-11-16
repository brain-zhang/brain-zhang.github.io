---
layout: post
title: "寻找并删除Git记录中的大文件"
date: 2018-04-26 13:36:16 +0800
comments: true
categories: develop
---

有时候gitignore没做好，一不小心就又进来一个二进制文件

在重复了N次Google之后，还是记一下吧

<!-- more -->

1. 首先通过rev-list来找到仓库记录中的大文件：


```
git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -5 | awk '{print$1}')"

```

2. 然后通过filter-branch来重写这些大文件涉及到的所有提交（重写历史记录）：


```
git filter-branch -f --prune-empty --index-filter 'git rm -rf --cached --ignore-unmatch your-file-name' --tag-name-filter cat -- --all

```

3. 再删除缓存的对象，顺便瘦身一下:


```
git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
git reflog expire --expire=now --all
git gc --prune=now

```

打完收工
