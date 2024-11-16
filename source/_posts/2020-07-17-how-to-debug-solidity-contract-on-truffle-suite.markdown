---
layout: post
title: "How to do logging on solidity contract with truffle suite"
date: 2020-07-17 17:33:45 +0800
comments: true
categories: blockchain
---

Ethereum的智能合约调试起来很麻烦，到目前为止还是没有一个方便的类似于console.log()或printf的调用；

一般都是通过Event的方法来打印log；这种办法在写单元测试的时候很麻烦；

目前最接近于官方的手段是构造一个公用的Console库合约，然后链接到主合约里面来用；

https://github.com/trufflesuite/truffle-logger-example

这个PR一直没有Merge到TruffleSuite的新版本中，我们只能先临时手工Copy下代码来Monkey Patch一下；

步骤如下：

* 首先在主合约的同级目录添加Console.sol合约:

```
wget https://raw.githubusercontent.com/trufflesuite/truffle/truffleLogger/packages/core/lib/logging/Console.sol
```

* 然后在部署脚本里面增加这个库的链接(以官方示例MetaCoin为例)

```
$ vim migrations/2_deploy_contracts.js
```


```
const Console = artifacts.require("Console");
const MetaCoin = artifacts.require("MetaCoin");

module.exports = function(deployer) {
      deployer.deploy(Console);
        deployer.link(Console, MetaCoin);
          deployer.deploy(MetaCoin);
          };

```

* 在需要打印log的单元测试中引入Console.sol

```
$ vim test/TestMetaCoin.sol
```

```
import "../contracts/Console.sol";

.....
    console.log("xxxxxx");
```
