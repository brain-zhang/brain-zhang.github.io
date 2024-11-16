---
layout: post
title: "Javascript设计模式 - 笔记2"
date: 2015-01-05 09:05:16 +0800
comments: true
categories: javascript_pattern develop
---
# 如何封装一个对象

## 门户大开型

最简单的办法就是按传统方法创建一个类，用一个函数来做其构造器。


```
var Book = function(isbn, title, author) {
    if (isbn === undefined) {
        throw new Error('Book constructor requires an isbn.');
    }
    this.isbn = isbn;
    this.title = title || 'No title specified';
    this.author = author || 'No title specified';
}

//define by attr
Book.prototype.display = function() {...};

//define by object literals
Book.prototype = {
    display: function(){...},
    checkIsdn: function(){...}
};

```

* 优点：简单
* 缺点：没有保护，需要加各种校验。但内部的成员还是有很大可能被修改的。

## 语法修饰增强型

用setattr,getattr等赋值取值方法及命名规范区别私有成员


```
var Book = function(isbn, title, author) {
    if (isbn === undefined) {
        throw new Error('Book constructor requires an isbn.');
    }
    this.setIsbn(isbn);
    this.setTitle(title);
    this.setAuthor(author);
}

//define by attr
Book.prototype.display = function() {...};

//define by object literals
Book.prototype = {
    _checkIsdn: function() {...}

    setIsbn: function(isbn) {
        if!(this._checkIsbn(isbn)) {
            throw new Error("Invalid isbn");
        }
        this._isbn = isbn;
    }

    getIsbn: function() {
        return this._isbn;
    }
    .......
};

```
* 优点：简单，安全性也有所增强
* 缺点：不是真正的私有成员，内部的成员还是有很大可能被修改的。

## 闭包实现私有成员


```
var Book = function(iisbn, ititle, iauthor) {

    //private attributes
    var isbn, title, author;

    //private method
    function _checkIsbn(iisbn) {
        ...
    }

    //privileged methods
    this.getIsbn = function() {
        return isbn;
    };

    this.setIsbn = function(iisbn) {
        this._checkIsbn(iisbn) ...
        isbn = iisbn;
    }

    .......

    //contructor code
    this.setIsbn(iisbn);
    this.setTitle(ititle);
    this.setAuthor(iauthor);
};

//public, non-privileged methods

Book.prototype = {
    display: fucntion(){},
    ....
}

```

这里应用了js的闭包特性，isbn等属性不再通过`this`来引用，而是放到函数的构造器里面。既要访问到私有成员，又要对外的方法放到函数的构造中，对私有成员没有依赖的函数用prototype。

* 优点：比较完整的模拟了private特性
* 缺点：private方法不再存在prototype里面，这样没生成一个新的对象实例都会为每个每个私有方法和特权方法生成一个新副本，耗费内存。

## 实现静态方法和属性


```
var Book = (function() {

    //private static attributes
    var numberOfBooks = 0;

    //private static method
    function checkIsbn(iisbn) {
        ...
    }

    //return the contructor
    return function(iisbn, ititle, iauthor) {
        //private attributes
        var isbn, title, author;

        //privileged methods
        this.getIsbn = function() {
            return isbn;
        };

        this.setIsbn = function(iisbn) {
            this._checkIsbn(iisbn) ...
            isbn = iisbn;
        }
        .......

        //contructor code
        numOfBooks++;
        this.setIsbn(iisbn);
    }
})();

//public, static methods
Book.converTotitleCase = function(){...};

//public, non-privileged methods

Book.prototype = {
    display: fucntion(){},
    ....
}

```

这里和`闭包实现私有成员`的区别就在于构造函数变成了一个内嵌函数，这样就创建了一个闭包，可以把静态的私有成员声明在最顶层。

## 实现常量

常量就设置为一个私有静态属性，用大写区分即可。我认为没有必要实现一个取值器去限制，用CONST前缀从代码风格上约束即可。
