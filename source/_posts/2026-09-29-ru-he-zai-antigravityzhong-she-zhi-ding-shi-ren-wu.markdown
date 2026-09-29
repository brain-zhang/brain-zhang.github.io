---
layout: post
title: "如何在Antigravity中设置定时任务"
date: 2026-09-29 21:44:59 +0800
comments: true
categories: ai
---

Antigravity中有设置定时任务的选项；但是界面设置，只能每次都开启一个新的session，如果指定每次定时任务都在一个session中完成，需要直接修改配置文件:

```
vim ~/.gemini/config/sidecars/merge-pr/sidecar.json



{
  "builtin": "schedule",
  "restart_policy": "always",
  "args": [
    "*/30 * * * *",
    "send-message",
    "bde19415-3acf-4bec-9147-8e9861186961",
    "--",
    "please exec `atb-github-pr-merge` skill, to merge test ok prs"
  ],
  "display_name": "merge pr"
}
```
