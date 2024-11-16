---
layout: post
title: "为Flask RestAPI集成Swagger UI"
date: 2019-08-18 15:38:02 +0800
comments: true
categories: develop
---

花了半天时间，给[chainhorn](https://github.com/brain-zhang/chainhorn)集成了Swagger;

虽然这种事情已经做过好几遍了，但是不读文档还是没辙；我把这种半吊子形容为“我认识人民币，但是画不出来...T_T”

还是老老实实流水账记一下吧:

<!-- more -->

### 依赖组件

* [flask-restplus](https://flask-restplus.readthedocs.io)

restplus能让人很方便的通过几个decorator就可以集成很漂亮的restapi，它提供了api命名空间、Request和Response解析以及Swagger UI的集成

另外，flask-restplus的文档和例子写的非常简洁清晰，赞一个。

* [flask-httpauth](https://flask-httpauth.readthedocs.io/en/latest/)

用来集成验证机制，支持基本的密码验证、Token验证；短小精悍，够用了


### 起步

引用官网的例子:

#### 构建api对象


```
from flask import Flask
from flask_restplus import Api, Resource, fields
from werkzeug.contrib.fixers import ProxyFix

app = Flask(__name__)
app.wsgi_app = ProxyFix(app.wsgi_app)

api = Api(app, version='1.0', title='Chainhorn API',
    description='A simple ChainHorn API',
)

ns = api.namespace('node', description='node operations')

```

最重要的是构建了`api`对象，这样就可以为后面的资源增加url路由、参数解析同能；

下面紧跟着构建了一个`ns` --`namespace`对象，作用是为不同的资源，不同的url分组，这样最后反映到界面上好看一点；

#### 修饰


```
@ns.route('')
  class NodeGetInfo(Resource):
      @ns_node.doc('get node info')
      def get(self):
          '''get node info'''
          info = spv.getinfo()
          return {'nodeinfo': info}, 200

```

最简单的，用`@ns.route('')`，就定义了根url， 然后后面的套路都是相似的，为资源实现get方法，就直接响应 http Get请求了；

#### Request参数处理

如果直接在url后面跟参数，那么很方便的用 `ns.param`定义一下即可:
下面这个函数就直接接受一个 `/broadcast/tx12345` 这样的tx12345作为参数`tx`


```
@ns.route('/broadcast/<string:tx>')
  class WalletBroadcastTx(Resource):
      @ns.doc('broadcast raw tx')
      @ns.param('tx', 'The transaction hash identifier')
      def post(self, tx):
          '''broadcast raw tx'''
          sendrawtransaction(spv, tx)
          return {'broadcast': 'ok'}, 200

```

如果要放在FormData里面，可以用`ns.expect`来限制；它可以接受一个对象传入；比如上面的例子，要把`tx`字段放到POST请求的Form Data中，要这样做:


```
TxModel = {'tx': fields.String(required=True, description='The hex tx')}
@ns.route('/broadcast')
  class WalletBroadcastTx(Resource):
      @ns.doc('broadcast raw tx')
      @ns.expect(TxModel, 200)
      def post(self, tx):
          '''broadcast raw tx'''
          sendrawtransaction(spv, api.payload['tx'])
          return {'broadcast': 'ok'}, 200

```

#### Response参数处理

同样的，如果需要返回一个对象，在界面上出现这个对象的详细描述信息，可以用`marshal_with`和`marshal_list_with`来修饰；

具体请参考:

https://flask-restplus.readthedocs.io/en/stable/parsing.html


#### 用户验证

例如，为API加上HTTP Token Auth，要用到`HTTPTokenAuth`对象；

首先我们先定义验证规则:


```
auth = HTTPTokenAuth()
tokens = {
  'APIKEY':'hello',
  "APPID": "chainhorn"
}

@auth.verify_token
def verify_token(token):
  if request.headers.get('APIKEY', '').strip()==tokens['APIKEY'] and \
     request.headers.get('APPID', '').strip() == tokens['APPID']:
      return True
  else:
      return False

```

然后在每个url 请求处理函数前面加上修饰符`auth_login_required`；比如我们最开始的例子:


```
@ns.route('')
class NodeGetInfo(Resource):
  @ns.doc('get node info')
  @auth.login_required
  def get(self):
      '''get node info'''
      info = spv.getinfo()
      return {'nodeinfo': info}, 200


```

这样后台验证就有了；那么前台输入呢？

这个例子里面，我们需要前台输入的时候在HTTP Header里面传入两个Key: APIKEY和APPKEY；直接用用Swagger UI自带的组件实现就可以了，把api对象构造为:


```
AUTHORIZATIONS = {
    'apikey': {
        'type': 'apiKey',
        'in': 'header',
        'name': 'APIKEY'
    },
    'appid': {
        'type': 'apiKey',
        'in': 'header',
        'name': 'APPID'
    }
}
api = Api(app,
        version='v1',
        authorizations=AUTHORIZATIONS,
        security=list(AUTHORIZATIONS.keys()),
        title='Chainhorn API',
        description='Chainhorn API',
)


```

这样默认所有的API访问都需要 在HTTP Header中传入两个Key: APIKEY和APPKEY，如果值不对的话就会访问失败；

此时前台的界面是这样的:

![Auth1](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/201908/bg3.jpg)

可以点击右上角的Authorize一次性设置所有API的访问密钥；

![Auth2](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/201908/bg4.jpg)

也可以在每个API的右上角设置访问密钥；

当然，我们目前的密钥是后台写死的，你可以引入一个三方库为每个用户生成不同的密钥存到数据库里面，然后每次验证~~~

### 综合例子

最后，在github上面有个集大成的例子,值得推荐

https://github.com/frol/flask-restplus-server-example


