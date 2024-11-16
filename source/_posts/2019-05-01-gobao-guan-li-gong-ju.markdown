---
layout: post
title: "Go包管理工具"
date: 2019-05-01 15:25:27 +0800
comments: true
categories: develop
---
真的，Go的包管理工具之发展过程充分体现了什么叫`折腾`。 (叹气~~~)

<!-- more -->

想想Java的Maven， Nodejs的NPM，还有我们赞颂一万遍也不过分的Python包管理，为什么生命总要浪费在这些事情上面呢？ 陷入了深深的沉思~~

从Go1.11版本发布Go MODULE之后，我希望这是最后一次折腾`包管理`这件事情，神呐，诚心诚意的祈祷中~~

摘抄备忘下：

## GO111MODULE

Modules 是作为 experiment feature 加入到不久前正式发布的 Go 1.11 中的。
按照 Go 的惯例，在新的 experiment feature 首次加入时，都会有一个特性开关，go modules 也不例外，GO111MODULE 这个临时的环境变量就是 go modules 特性的 experiment 开关。

* off: go modules experiment feature 关闭，go compiler 会始终使用 GOPATH mode，即无论要构建的源码目录是否在 GOPATH 路径下，go compiler 都会在传统的 GOPATH 和 vendor 目录 (仅支持在 GOPATH 目录下的 package) 下搜索目标程序依赖的 go package；

* on: 始终使用 module-aware mode，只根据 go.mod 下载 dependency 而完全忽略 GOPATH 以及 vendor 目录
* auto: Golang 1.11 预设值，使用 GOPATH mode 还是 module-aware mode，取决于要构建的源码目录所在位置以及是否包含 go.mod 文件。满足任一条件时才使用 module-aware mode:
    - 当前目录位于 GOPATH/src 之外并且包含 go.mod 文件
    - 当前目录位于包含 go.mod 文件的目录下

## go mod 命令


```
download    download modules to local cache (下载依赖的 modules 到本地 cache)
edit        edit go.mod from tools or scripts (编辑 go.mod 文件)
graph       print module requirement graph (打印模块依赖图)
init        initialize new module in current directory (再当前文件夹下初始化一个新的 module, 创建 go.mod 文件)
tidy        add missing and remove unused modules (增加丢失的 modules，去掉未用的 modules)
vendor      make vendored copy of dependencies (将依赖复制到 vendor 下)
verify      verify dependencies have expected content (校验依赖)
why         explain why packages or modules are needed (解释为什么需要依赖)

```

## 既有项目

假设你已经有了一个 go 项目， 比如在$GOPATH/github.com/brain-zhang/hello下， 你可以使用go mod init github.com/brain-zhang/hello在这个文件夹下创建一个空的 go.mod (只有第一行 module github.com/brain-zhang/hello)。

然后你可以通过 go get ./...让它查找依赖，并记录在 go.mod 文件中 (你还可以指定 -tags, 这样可以把 tags 的依赖都查找到)。

通过go mod tidy也可以用来为 go.mod 增加丢失的依赖，删除不需要的依赖，但是我不确定它怎么处理tags。

执行上面的命令会把 go.mod 的latest版本换成实际的最新的版本，并且会生成一个go.sum记录每个依赖库的版本和哈希值。

## replace

在国内访问golang.org/x的各个包都需要梯子，你可以在 go.mod 中使用replace替换成 github 上对应的库。


```
replace (
  golang.org/x/crypto v0.0.0-20180820150726-614d502a4dac => github.com/golang/crypto v0.0.0-20180820150726-614d502a4dac
  golang.org/x/net v0.0.0-20180821023952-922f4815f713 => github.com/golang/net v0.0.0-20180826012351-8a410e7b638d
  golang.org/x/text v0.3.0 => github.com/golang/text v0.3.0
)

```
依赖库中的replace对你的主 go.mod 不起作用，比如github.com/brain-zhang/hello的 go.mod 已经增加了replace, 但是你的 go.mod 虽然require了rpcx的库，但是没有设置replace的话， go get还是会访问golang.org/x。

所以如果想编译哪个项目，就在哪个项目中增加replace。

## 包的版本控制

下面的版本都是合法的：


```
gopkg.in/tomb.v1 v1.0.0-20141024135613-dd632973f1e7
gopkg.in/vmihailenco/msgpack.v2 v2.9.1
gopkg.in/yaml.v2 <=v2.2.1
github.com/tatsushid/go-fastping v0.0.0-20160109021039-d7bb493dee3e
latest

```
版本号遵循如下规律：


```
vX.Y.Z-pre.0.yyyymmddhhmmss-abcdefabcdef
vX.0.0-yyyymmddhhmmss-abcdefabcdef
vX.Y.(Z+1)-0.yyyymmddhhmmss-abcdefabcdef
vX.Y.Z

```
也就是版本号 + 时间戳 + hash，我们自己指定版本时只需要制定版本号即可，没有版本 tag 的则需要找到对应 commit 的时间和 hash 值。

另外版本号是支持 query 表达式的，其求值算法是 “选择最接近于比较目标的版本 (tagged version)”，即上文中的 gopkg.in/yaml.v2 会找不高于 v2.2.1 的最高版本。


## go get 升级

* 运行 go get -u 将会升级到最新的次要版本或者修订版本 (x.y.z，z 是修订版本号， y 是次要版本号)
* 运行 go get -u=patch 将会升级到最新的修订版本
* 运行 go get package@version 将会升级到指定的版本号version


## go modules 与 vendor

* 在最初的设计中，Russ Cox 是想彻底废除掉 vendor 的，但在社区的反馈下，vendor 得以保留，这也是为了兼容 Go 1.11 之前的版本。

* Go modules 支持通过go mod vendor命令将某个 module 的所有依赖保存一份 copy 到 root module dir 的 vendor 下，然后在构建的使用go build -mod=vendor即可忽略 cache 里的包而只使用 vendor 目录里的版本。


## 参考:

https://roberto.selbach.ca/intro-to-go-modules/

https://github.com/golang/go/wiki/Modules

https://windmt.com/2018/11/08/first-look-go-modules/

