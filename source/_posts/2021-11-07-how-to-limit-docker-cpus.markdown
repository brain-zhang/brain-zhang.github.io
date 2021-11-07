---
layout: post
title: "how to limit exists running docker container cpus"
date: 2021-11-07 11:05:44 +0800
comments: true
categories: linux, docker, tools
---

```
docker update --cpu-period=100000 --cpu-quota=40000  <container>
```

意思是cpu时间切分为100000份，指定容器占用40000份，即cpu占用率最高40%
