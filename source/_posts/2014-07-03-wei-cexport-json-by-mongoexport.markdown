---
layout: post
title: "export json by mongoexport"
date: 2014-07-03 00:46:23 +0000
comments: true
categories:mongoexport
---

Exp:

    mongoexport -d foo -c exp -o exp.json -q '{"ts":{"$gte":0}}'

Notice:

    You should use `"`  not  `'` in query string
