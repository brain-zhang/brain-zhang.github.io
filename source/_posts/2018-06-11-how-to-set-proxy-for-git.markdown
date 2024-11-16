---
layout: post
title: "how to set proxy for git"
date: 2018-06-11 11:12:20 +0800
comments: true
categories: tools
---

### 全局设置和取消:


```
git config --global https.proxy http://127.0.0.1:1080

git config --global https.proxy https://127.0.0.1:1080

git config --global --unset http.proxy

git config --global --unset https.proxy

```


### local设置和取消:


```
git config  https.proxy http://127.0.0.1:1080

git config  https.proxy https://127.0.0.1:1080

git config  --unset http.proxy

git config  --unset https.proxy

```

