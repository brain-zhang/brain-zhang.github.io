---
layout: post
title: "How to remove all non-ascii content from a workflow (file)"
date: 2021-04-17 09:46:10 +0800
comments: true
categories: tools
---

#### grep remove lines

```
grep --colour='auto' -P '[^\x00-\x7]' file
```

#### tr remove characters

```
LC_ALL=C tr -dc '\0-\177' <file >newfile
```


#### ignore Invalid or incomplete multibyte or wide character

```
cat $file|iconv -f utf8 -c -t ascii//IGNORE
```
