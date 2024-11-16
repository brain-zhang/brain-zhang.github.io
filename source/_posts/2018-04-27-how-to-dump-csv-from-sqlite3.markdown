---
layout: post
title: "how to dump csv from sqlite3"
date: 2018-04-27 08:57:22 +0800
comments: true
categories: tools
---


```
#!/bin/bash

/usr/bin/sqlite3 test.db <<!
.headers on
.mode csv
.output out.csv
select username,password,email from passhouse order by site;
!

```
