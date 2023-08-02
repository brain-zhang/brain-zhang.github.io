---
layout: post
title: "Ios dev and Xcode Cheat"
date: 2023-08-02 15:30:42 +0800
comments: true
categories: tools
---

自学Swfit开发了一个App，记录一下坑:

* Swift和ObjectC混编的时候，检查 `ProjectName--Bridging-Header.h` 文件是否被指定为桥接文件 : `Target-> Build Settings ->Swift Compiler -> Install Object-C Compatibility  Header` 设置为Yes， `Target->Build Settings -> Swift Compiler ->Object-C Briding Header` 是否设置为这个文件

* `xxx-Bridging-header.h` 文件内容一般是 swift的头文件和公共的头文件，内容一般是

```
	#import "xxx.h"
```

* 当引用类似 `#import "happynet-Swfit.h"` 提示找不到的时候， 请检查引用次序，类似:

```
@import TestDylib;

#include "xxx-Swift.h"

#import "xxxmanager.h"
```

* 编译提示少符号的时候，检查 `Target-> Build Phases-> Compile Sources` 是否把所有文件添加进去了
* 调试第三方库，例如Tunnel的时候，先用 `Debug->Attach To Process by PID Or Name` 挂载进程
* 如果是线程错误，xcode会弹出一个Text Table，显示汇编指令哪一行有问题，同时临近的Table回显示代码文件中对应的哪一行，一般是淡绿色标注那一行
* 如果出现莫名其妙的编译错误，先`Build -> Clean Build xxx`；清理一下，重新编译试试

