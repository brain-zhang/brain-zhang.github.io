---
layout: post
title: "Javascript设计模式 - 笔记3"
date: 2015-01-24 11:30:02 +0800
comments: true
categories: javascript_pattern develop
---
javascript 里面的继承是个非常复杂的话题，一言蔽之，就是你要替解释器干点活。另外，javascript属于使用原型式继承的语言，这个比较少见，所以直觉上不好拐弯。

先回顾比较简单的办法

## 类式继承

### 一个简单的类


```
/* class Person */
function Person(name) {
    this.name = name;
}

Person.prototype.getName = functino() {
    return this.name;
}

var reader = new Person('brainzhang');
reader.getName();

```

好，下面定义一个它的子类


```
/* Class Author */
function Author(name, books) {
    Person.call(this, name);
    this.books = books;
}
Author.prototype = new Persion();  //set up the prototype chain
Author.prototype.contructor = Author; //set the constructor attribute to author
Author.getBooks = function() {return this.books;}

```

容易费解的是这两行:

```
Author.prototype = new Persion();  //set up the prototype chain
Author.prototype.contructor = Author; //set the constructor attribute to author

```

javascript中，每个对象都有一个原型对象，在创建一个对象时，javascript会自动将其原型对象设置为其构造函数的prototype属性所指的对象。
在访问对象的某个成员时，如果这个成员未见于当前对象，那么javascript会沿着原型链向上逐一访问每个原型对象(最顶端为Object.prototype对象)，直到找到这个成员为止。
这意味着，为了让一个类继承另一个类，只需将子类的prototype设置为基类的一个实例即可。

第二行将prototype的constructor属性重新设置为Author。是因为:
定义一个构造函数时，其默认的prototype对象是一个Object类型的实例，其contructor属性会被设置为构造函数本身。如果手工将prototype设置为另一个对象，就要重新设置其constructor属性。

最后，为了简化类的声明，可以将这些工作封装在extend函数中:


```
function extend(subClass, superClass) {
    var F = function(){};
    F.prototype = superClass.prototype;
    subClass.prototype = new F();
    subClass.prototype.contructor = subClass;
}

```
作为改进，定义了一个新对象F，避免基类对象过大，创建实例浪费资源。

但是这样还有个小缺点，声明 Author的时候，还要显式的调用一下`Person.call()`，下面这个版本进一步做了改进：

```
function extend(subClass, superClass) {
    var F = function(){};
    F.prototype = superClass.prototype;
    subClass.prototype = new F();
    subClass.prototype.contructor = subClass;

    subClass.superclass = superClass.prototype;
    if(superClass.prototype.contructor == Object.prototype.constructor) {
        superClass.prototype.contructor = superClass;
    }
}

```

增加了一个superclass属性来直接访问基类，这样声明Author的时候可以这么写:

```
/* Class Author */
function Author(name, books) {
    Author.superclass.contructor.call(this, name);
    this.books = books;
}
extend(Author, Person);
Author.getBooks = function() {return this.books;}

```

## 原型式继承
TODO
