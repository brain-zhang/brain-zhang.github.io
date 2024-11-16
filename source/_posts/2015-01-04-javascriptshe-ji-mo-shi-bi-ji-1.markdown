---
layout: post
title: "javascript设计模式 - 笔记1"
date: 2015-01-04 08:25:15 +0800
comments: true
categories: javascript_pattern develop
---
# 富有表现力的javascript

## 弱类型语言

javascript中有三种原始类型:布尔型、数值型(不区分浮点数和整数)和字符串型。

此外，还有对象类型和包含可执行代码的函数类型。前者是一种复合类型(数组是一种特殊的对象)。

最后，还有空类型(null)和未定义类型(undefined)。

原始数据类型按值传送，其他数据类型则按引用传送。

## 函数是一等对象

* 匿名函数


```
(function(){
    var foo = 10;
    var bar = 2;
    alert(foo * bar);
})();

```

* 闭包


```
var baz;
(function(){
    var foo = 10;
    var bar = 2;
    baz = function(){
        return foo * bar;
    }
})();
baz(); //baz可以访问foo和bar，即使是在匿名函数外面执行

```

* 作用域、嵌套函数和闭包

    * js中，只有函数具有作用域：

        在一个函数内部声明的变量，外部无法访问；
        定义在一个函数中的变量在该函数的内嵌函数中是可以访问的

    * js中的作用域是词法性的：

        函数运行在定义他们的作用域中，而不是调用他们的作用域中；
        可以利用这个特性定义静态方法和属性；

## 对象的易变性(mutable)和内省(introspection)

* 易变性：js中可以对象前定义的类和实例化的对象进行修改
* 内省：js中可以在运行时检查对象所具有的属性和方法

# 接口

* 接口也是一种对象，判断一个类是否是实现了某类接口，就是传入这个接口，而后比较。

    java有专门的接口类，C++有虚基类，而C在linux kernel中的对象设计方法实际上也是一种接口实现，这都是接口在语言层面支持的体现

* 封装(encapsulation)和信息隐藏：信息隐藏是目的，而封装则是藉以达到这个目的的技术

    java和C++有 private关键字作为支持，Python有'__'的命名约定，js中一般用闭包来模拟

## 接口实现

### 用注释来模拟


```
/*
interface Composite {
    function add(child);
    function remove(child);
    ...
}

interface FormItem{
    function save();
}

var CompositeForm = function(id, method, action) {
    //implements Composite, FromItem
    ...
};

CompositeForm.prototype.add = function(child) {
    ...
}
CompositeForm.prototype.remove= function(child) {
    ...
}
CompositeForm.prototype.save= function() {
    ...
}


```

* 优点：简单明了，代码体积小
* 缺点：无法错误检查

### 用属性检查模仿接口

约定所有类明确声明实现了那些接口，和这些类打交道的对象可以针对这些声明做检查。


```
/*
interface Composite {
    function add(child);
    function remove(child);
    ...
}

interface FormItem{
    function save();
}

var CompositeForm = function(id, method, action) {
    //implements Composite, FromItem
    this.implementsInterfaces = ['Composite', 'FromItem'];
    ...
};
    ...

function addForm(formInstance) {
    if (!implements(formInstance, 'Composite', 'FormItem')) {
        throw new Error("object does not implement a required interface");
    }
}

function implements(objects) {
    for (var i = 1; i < arguments.length; i++) {
        var interfaceName = arguments[i];
        var interfaceFound = false;
        for (var j = 0; j < object.implementsInterfaces[j] == interfaceName) {
            interfaceFound = true;
            break;
        }
        if (!interfaceFound) {
            return false;
        }
    }
    return true;
}


```

* 优点:有错误检查
* 缺点:每次调用都要检查，啰嗦，另外防不住有说了实现但没有干活的

# 鸭式辨型模仿接口


```
var Composite = new Intreface('Composite', ['add', 'remove']);
var FormItem = new Interface('FormItem', ['save']);
var CompositeForm = function(id, method, action) {
    ...
};

function addForm(formInstance) {
    ensureImplements(formInstance, Composite, FormItem);
    ......
}

var Interface = function(name, methods) {
    if (arguments.length != 2) {
        throw new Error("Interface constructor called with " + arguments.length + "arguments, but expected exactly 2.");
    }
    this.name = name;
    this.methods = [];
    for (var i = 0; len = methods.length; i < len; i++) {
        if (typeof methods[i] !== 'string')  {
            throw new Error("Interface contructor expects method names to be " +
                            "passed in as string");
        }
    }
    this.methods.push(methods[i]);
}

Interface.ensureImplements = function(object) {
    if (arguments.length < 2) {
        throw Error("Functino Interface.ensureImplements called with " + arguments.length +
                    "arguments, but expected at leaset 2.");
    }

    for (var i = 1, len = arguments.length; i < len; i++) {
        if (interface.constructor !== Interface) {
            throw new Error("Function Interface.ensureImplements expects arguments" +
                            "two and above to be instances of Interface.");
        } 
    }

    for (var j = 1, methodsLen = interface.methods.length; j < methodsLen; j++) {
        var method = interface.methods[j];
        if(!object[method] || typeof object[method] !== 'function') {
            throw new Error("Function Interface.ensureImplements: object " +
                            "does not implement the " + interface.name)  +
                            "interface.Method " + method + " was not found.");
        }
    }
}


```

* 优点：进一步加强了错误检查
* 缺点：增大了调试难度

