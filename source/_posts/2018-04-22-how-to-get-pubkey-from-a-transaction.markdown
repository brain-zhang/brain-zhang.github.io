---
layout: post
title: "how to get pubkey from a transaction"
date: 2018-04-22 20:42:49 +0800
comments: true
categories: blockchain
---

比如`1HUBHMij46Hae75JPdWjeZ5Q7KaL7EFRSD`，这个地址，有转出过，如何得到公钥

原理很简单，但是实践起来比较烦：

<!-- more -->

首先我们找一下这个地址的随便一笔花费，比如这个:

https://btc.com/0998ef06442994c147aec242e6973dfe3d512b05bde880793051a48bd021fc33


然后需要一个工具通过交易hash解析一下这笔交易

推荐用这个 [libbitcoin/libbitcoin-explorer](https://github.com/libbitcoin/libbitcoin-explorer/wiki/Download-BX)

执行

    bx-windows-x64-icu.exe fetch-tx 0998ef06442994c147aec242e6973dfe3d512b05bde880793051a48bd021fc33

得到了这笔交易解析后的完整输出:


```
transaction
{
    hash 0998ef06442994c147aec242e6973dfe3d512b05bde880793051a48bd021fc33
    inputs
    {
        input
        {
            address_hash b4a5d3960471568c3883046eec3b41b4953d61a1
            previous_output
            {
                hash 5fb9f0e7f520163e4afe0baa440fe93999273e95d9e345e0488a0802ed62674f
                index 0
            }
            script "[3045022100e4a4695ecbe6f507ec7181a2f321f489c7a3bd7eea032c75e4e1eba89174183c022019555aa917be6191db14da72e5c234a4b628f321b917ea334bcf9c122296cd5901] [044da006f958beba78ec54443df4a3f52237253f7ae8cbdb17dccf3feaa57f3126da0a0909f11998130c2d0e86a485f4e79ee466a183a476c432c68758ab9e630b]"
            sequence 4294967295
        }
    }
    lock_time 0
    outputs
    {
        output
        {
            address_hash c621cbfd778e6109e26046d96738c7af75e7b78b
            script "dup hash160 [c621cbfd778e6109e26046d96738c7af75e7b78b] equalverify checksig"
            value 43103
        }
    }
    version 1
}

```

注意script那一段，就是分成了两部分，前面一个中括号里面是签名，后面是公钥。

然后仔细看看这还是个老钱包生成的地址，没有压缩;



写个小脚本parse一下这个公钥，就可以看看是不是和地址对应啦:


```
#!/usr/bin/env python

from hashlib import *
from base58 import *

def SHA256D(bstr):
    return sha256(sha256(bstr).digest()).digest()

def ConvertPKHToAddress(prefix, addr):
    data = prefix + addr
    return b58encode(data + SHA256D(data)[:4])

def PubkeyToAddress(pubkey_hex):
    pubkey = bytearray.fromhex(pubkey_hex)
    round1 = sha256(pubkey).digest()
    h = new('ripemd160')
    h.update(round1)
    pubkey_hash = h.digest()
    return ConvertPKHToAddress(b'\x00', pubkey_hash)

pubkey = "044da006f958beba78ec54443df4a3f52237253f7ae8cbdb17dccf3feaa57f3126da0a0909f11998130c2d0e86a485f4e79ee466a183a476c432c68758ab9e630b"
print(len(pubkey))
print("Address: %s" % PubkeyToAddress(pubkey))

```


输出是这样的:


```
130
Address: 1HUBHMij46Hae75JPdWjeZ5Q7KaL7EFRSD

```


OK，打完收工。

如果一个地址只收币，从来没消费币，公钥是不会广播到网上的，所以这种地址拿不到公钥。一定要有花费，才能得到公钥。


所以有人推荐每次花费币之后就不要再用老地址了，每次交易都用新地址，避免将来出现什么黑科技（比如量子计算机之类的）穷举破解。 其实我觉的无所谓，大不了有人喊ECDSA挂了我再转移一下就行了，人家富豪榜里面都有好几个大佬也不在乎这点事。

PS:更新自打脸一下，我还是觉得每次交易用新地址是一定要做的，理论上HASH碰撞的概率有2^160，但是我现在觉得这个量级不能简单的推算为1/2^160；毕竟不是所有的钱包实现熵值都足够大。尽可能每次交易用新地址会增加碰撞库更新的难度。

#### 再强调一遍，每次交易用新地址是一个必须养成的习惯。

另外公钥有两种形式：压缩与非压缩。一把私钥其实可以搞出两个地址哈。早期比特币均使用非压缩公钥，现大部分客户端已默认使用压缩公钥。早期openssl库的文档写的比较糙，导致Satoshi以为必须使用非压缩的完整公钥，后来大家发现其实公钥的左右两个32字节是有关联的，左侧(X)可以推出右侧(Y)的平方值，有左侧(X)就可以了。
