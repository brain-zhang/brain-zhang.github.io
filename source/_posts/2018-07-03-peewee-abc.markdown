---
layout: post
title: "Peewee ABC"
date: 2018-07-03 11:10:09 +0800
comments: true
categories: develop python
---

在我用了又一个小时的时间去温习sqlchemy丰富的文档后，我放弃治疗了。

我的智商还是适合比较简单的幼儿化的Python库，于是我转向Peewee了。


## 定义Model


```
from peewee import SqliteDatabase, Model, CharField

db = SqliteDatabase('testdb.sqlite3')

class User(Model):
    username = CharField(index=True)
    password = CharField()
    email = CharField(index=True)
    birthday = DateField()
    is_relative = BooleanField()

    class Meta:
        database = db


```

## 创建


```
>>> db.connect()
>>> db.create_tables([User])

```

## 保存


```
>>> user_record = User(name='Bob', password="", email="hello@world.com", birthday=date(1960, 1, 15), is_relative=True)
>>> user_record.save()


```


## 批量插入


```
fields = [User.username, User.password, User.email, User.birthday, User.is_relative]
user_records.append(
    (username, password, email, birthday, True),
    (username, password, email, birthday, True),
    (username, password, email, birthday, True),
)
User.insert_many(user_records, fields=fields).execute()


```


## 查询


```
for user in User.select().where(User.username.contains(username)):
    print(user.username ....)

```


## 关闭


```
>>> db.close()

```
