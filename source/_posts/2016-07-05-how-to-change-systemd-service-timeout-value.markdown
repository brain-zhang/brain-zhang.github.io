---
layout: post
title: "How to change systemd service timeout value"
date: 2016-07-05 17:56:04 +0800
comments: true
categories: linux tools
---

# show value


```
systemctl show SERVICE_NAME.service -p TimeoutStopUSec

```

# change value


```
vim /usr/lib/systemd/system/node.service

```
TimeoutStopUSec = 900

```
systemctl daemon-reexec

```
