---
layout: post
title: "How to close lightning channels by lnd-cli?"
date: 2021-01-03 16:54:10 +0800
comments: true
categories: blockchain lightning
---

越来越有老年痴呆的倾向，这个命令至少Google过3次了，每次都忘，被自己蠢哭了~~

```
lncli closechannel <fund_txid> [fund_tx_vout_NO]
```

不要忘了vout_NO，不然会报错"channel not found"
