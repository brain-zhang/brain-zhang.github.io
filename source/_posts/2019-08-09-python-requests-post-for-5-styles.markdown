---
layout: post
title: "Python requests post for 5 styles"
date: 2019-08-09 09:13:32 +0800
comments: true
categories: develop
---

#### requests库发送post请求的五种姿势;

<!-- more -->

#### 1.application/x-www-form-urlencoded

最常见的 POST 提交数据的方式了。浏览器的原生 form 表单，如果不设置 enctype属性，那么最终就会以 application/x-www-form-urlencoded方式提交数据。请求类似于下面这样:


```
POST http://www.example.com HTTP/1.1    Content-Type:
application/x-www-form-urlencoded;charset=utf-8
title=test&sub%5B%5D=1&sub%5B%5D=2&sub%5B%5D=3

```

requests默认处理就是这种方式， exp:


```
url = 'http://httpbin.org/post'
d = {'key1': 'value1', 'key2': 'value2'}
r = requests.post(url, data=d)
print r.text

```

#### 2.multipart/form-data

除了传统的application/x-www-form-urlencoded表单，我们另一个经常用到的是上传文件用的表单，这种表单的类型为multipart/form-data。
这又是一个常见的 POST 数据提交的方式。我们使用表单上传文件时，必须让 form 的 enctyped 等于这个值:

requests exp:

```
from requests_toolbelt import MultipartEncoder
import requests

m = MultipartEncoder(
    fields={'field0': 'value', 'field1': 'value',
            'field2': ('filename', open('file.py', 'rb'), 'text/plain')}
    )

r = requests.post('http://httpbin.org/post', data=m,
                  headers={'Content-Type': m.content_type})

```

#### 3.application/json

application/json 这个 Content-Type作为响应头大家肯定不陌生。实际上，现在越来越多的人把它作为请求头，用来告诉服务端消息主体是序列化后的 JSON 字符串。

requests exp:

```
url = 'http://httpbin.org/post'
s = json.dumps({'key1': 'value1', 'key2': 'value2'})
r = requests.post(url, data=s)
print r.text

```

or

```
requests.post(url='',data=json.dumps({'key1':'value1','key2':'value2'}),headers={'Content-Type':'application/json'})

```

or


```
requests.post(url='',json={{'key1':'value1','key2':'value2'}},headers={'Content-Type':'application/json'})

```

#### 4. text/xml
跟json类似，XML 作为编码方式的远程调用规范。

requests exp:

```
requests.post(url='',data='<?xml  ?>',headers={'Content-Type':'text/xml'})

```

#### 5. binary

直接二进制流数据传输，多用于上传图片

requests exp:


```
requests.post(url='',files={'file':open('test.xls','rb')},headers={'Content-Type':'binary'})

```

or


```
url = 'http://httpbin.org/post'
files = {'file': open('report.txt', 'rb')}
r = requests.post(url, files=files)
print r.text

```
