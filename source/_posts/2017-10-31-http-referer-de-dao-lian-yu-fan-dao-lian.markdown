---
layout: post
title: "http referer 的盗链与反盗链"
date: 2017-10-31 21:47:27 +0800
comments: true
categories: develop
---

HTTP的图片防盗链技术基本上人民群众喜闻乐见了。 今天突然发现一种比较通用的隐藏referer来反盗链的hack手段，记录之。


简单来说，Referer是HTTP协议中的一个请求报头，用于告知服务器用户的来源页面。比如说你从Google搜索结果中点击进入了某个页面，那么该次HTTP请求中的Referer就是Google搜索结果页面的地址。

一般Referer主要用于统计，像CNZZ、百度统计等可以通过Referer统计访问流量的来源和搜索的关键词（包含在URL中）等等，方便站长们有针性对的进行推广和SEO什么的~

当然Referer另一个用处就是防盗链了，主要是图片和网盘服务器使用的较多。盗链的危害不言而喻，侵犯了版权不说，增加了服务器的负荷，却没有给真正的服务提供者带来实际利益（广告点击什么的）

另外要注意的是，Referer是由浏览器自动为我们加上的，以下情况是不带Referer的

* 直接输入网址或通过浏览器书签访问

* 使用JavaScript的Location.href或者是Location.replace()

* HTTPS等加密协议

很多网站挟持脚本一般是注入https链接来隐藏referer，这样固然好用，但是一定要一个域名，有点不方便。前人实践发现只要在iframe里面的src属性填上 `javascript: <html>....`的内容就可以隐藏referer了。一试果然如此。

比如大家常见的微信公众号文章，如果引用过来，一般就是防盗链了，这个时候可以用下面的通用代码解决：

* 需要引用jquery和 [ReferrerKiller.js](https://github.com/jpgerek/referrer-killer) 这两个库:


```
   jQuery(function() {
       //遍历所有的img元素，凡是QQ和微信引用的统统放到iframe里面
       jQuery("div").find("img").each(function() {
           var img = jQuery(this);
           var img_src = img.attr("src");
           if (img_src != undefined && img_src != '') {
               img_src = decodeURI(img_src);
               img_src = img_src.split("?")[0];
               if (img_src.indexOf("qpic.cn") > 0 || img_src.indexOf("qlogo.cn") > 0 || img_src.indexOf("qq.com") > 0) {
                   var frameid = 'frameimg' + Math.random();
                   img.parent().append('<span id="' + frameid + '"></span>')
                   img.remove();
                   document.getElementById(frameid).innerHTML = ReferrerKiller.imageHtml(img_src);
               }
           }
       })
   })

```

这样看出来的效果就是原来引用微信的图片:

    <img src="http://mmbiz.qpic.cn/mmbiz/cfxQzmUp8b0E12wMVv6SzROhSAgmxENxKPSQibVNhXAx8vr3BQW1lnlakR8wDVLc38QSZwnRfiaDtPZ0d3PhBMtQ/640?"/>

就会被替换到iframe里面，同时iframe的src属性包括了完整的html内容，这样浏览器请求图片的时候，就不会带referrer了，微信的盗链就被绕过。


不知道微信啥时候堵上这个洞呢？


