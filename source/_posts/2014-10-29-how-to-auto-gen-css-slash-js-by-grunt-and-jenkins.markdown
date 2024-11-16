---
layout: post
title: "how to auto gen css/js by grunt and jenkins"
date: 2014-10-29 12:16:15 +0800
comments: true
categories: grunt jenkins tools
---

虽然有[grunt-contrib-watch](https://github.com/gruntjs/grunt-contrib-watch)的存在，但多个人编辑同一份css/js代码时，还要操心编译这个事，实在是多余。

想到的最直接的办法就是jenkins上开一个项目，自动编译一把，再自动提交:

虽然是野路子，但效果那是杠杠的。

记一下一些要注意的点:

 - 有时候自动编译会失败，需要标记一下:


```
/usr/local/node-v0.10.20-linux-x64/bin/grunt --force |tee $PWD_DIR/grunt.log
err_count=`grep 'Error' $PWD_DIR/*.log|wc -l`
fail_count=`grep 'failed' *.log|wc -l`
abort_count=`grep 'Aborting' *.log|wc -l`
if [[ $err_count -gt 0 || $fail_count -gt 0 || $abort_count -gt 0 ]]; then
    exit 1
fi

```

这样jenkins编译失败，就会标红了

 - 还有个坑，有时候新增加了一个js的代码目录，这样编译后也会多一个目录，这就需要svn每次提交的时候，不要忘了强制add一下当前所有目录:


```
svn add static/dist/ --force

```

 - 最后，极少数的情况编译后会出现冲突，因为编译的时候有人同样编译了一把提交了，这样自动提交会失败，也需要标记一下:


```
svn ci --no-auth-cache --username=xxx --password=xxx static/dist/* -m "jenkins:auto grunt" 2>&1| tee $PWD_DIR/svn.log
err_count=`grep 'Error' $PWD_DIR/*.log|wc -l`
fail_count=`grep 'failed' *.log|wc -l`
abort_count=`grep 'Aborting' *.log|wc -l`
if [[ $err_count -gt 0 || $fail_count -gt 0 || $abort_count -gt 0 ]]; then
    exit 1
fi

```

这样基本上看看jenkins的状态，或是让jenkins自动发发邮件，就舒心了。
