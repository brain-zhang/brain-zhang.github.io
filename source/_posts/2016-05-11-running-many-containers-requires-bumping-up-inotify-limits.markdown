---
layout: post
title: "Running many containers requires bumping up inotify limits"
date: 2016-05-11 15:11:19 +0800
comments: true
categories: docker tools
---

when we see `Too many open files - failed to inotify_init`, we could either bump up the limit automatically, or tell the user.

just exec:

    sysctl -w fs.file-max=64000
    sysctl -w fs.inotify.max_user_instances=8192
