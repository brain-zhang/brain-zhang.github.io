---
layout: post
title: "Python编程实战 - 笔记1"
date: 2015-04-27 08:17:45 +0800
comments: true
categories: develop DesignPattern
---

这本书讲的挺实在的，设计模式的部分又复习了一遍。另外又学了几个Python3的新decorator。

## 创建型设计模式

#### 抽象工厂 (Abstract Factory)

* 名字就用AbstractFactory好了，不要起什么BaseFactory之类的
* 相关类都放到对应的Factory Class里面，不要暴露给外面了

#### 建造者模式 (Build)

* 和工厂的区别就是保存了创建对象时各个部分的细节

#### 工厂模式

* 根据情况实例化对象
* 还是注意和抽象工厂的区别，抽象工厂是将创建对象的行为抽象出来，而工厂模式则是根据要创建的对象类型实例化

#### 原型模式 (Prototype)

* 这个模式其实在javascript的根本，不过Python的实现方法还真是五花八门，我说直接用copy就好了嘛

#### 单例模式 (Singleton)

* 我最中意的一种实现:


```
    class Borg:
        _shared_state = {}
        def __init__(self):
            self.__dict__ = self._shared_state

    class Singleton(Borg):
        def __init__(self, arg):
            Borg.__init__(self)
            self.val = arg
        def __str__(self):
            return self.val

```

## 结构型设计

* 作用就是改装对象，或者把小对象合并为大对象

#### Adapter

* 其实就是转接方法

#### Bridge

* 把方法抽象出来

#### Composite

* Python里面有一种省一点内存的写法，可以直接用CompositeItem和Item两个类来实现，不过我觉得不直观

#### decorator

* 几个新的decorator:

    * `@functools_wraps` : 装饰器工厂

    * `@statically_typed` : 类型检查

* 另外`@ensure`类修饰符可以用来简化设置property的代码

#### Facade

* 这个模式其实是天天在做的，就是把接口聚合的好看一点
* 其实思想可以推广到很多方面，比如Docker，就是LXC的一个Facader，而且做的比较好看，于是大家就都来用了

#### Flyweight

* 管理许多小对象的时候用引用
* Python用`__slot__` Attribute来做最方便
* 里面关于用shelve对象存储class attribute的思路挺实用的
