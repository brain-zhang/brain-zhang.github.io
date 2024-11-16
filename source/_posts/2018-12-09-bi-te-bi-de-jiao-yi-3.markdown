---
layout: post
title: "比特币的交易-3"
date: 2018-12-09 15:46:05 +0800
comments: true
categories: blockchain
styles: data-table
---

## scriptSig与scriptPubKey概览

继续解析我们上篇文章的交易(`b0a0afb65ac08f453b26fa03a40215be653b6d173510d366321019ab8248ea3b`)

目前为止，我们还没有解析vin中的scriptSig，以及vout中的scriptPubKey；这两个东东才是交易的核心，他们有什么作用呢？

<!-- more -->

scriptSig是一笔UTXO的开锁脚本，scriptPubKey是输出UTXO的加锁脚本，一笔交易就是打开上家的保险箱，将资金转移到下家的保险箱并重新加锁的过程:

* 上家-TransA: id(b0a0afb65ac08f453b26fa03a40215be653b6d173510d366321019ab8248ea3b) -> vout scriptPubkey (转移到保险箱A，并给A上锁)

```
			{
				"value": 0.00010000,
				"n": 0,
				"scriptPubKey": {
					"asm": "OP_DUP OP_HASH160 650d0497e014e60d4680fce6997d405de264f042 OP_EQUALVERIFY OP_CHECKSIG",
					"hex": "76a914650d0497e014e60d4680fce6997d405de264f04288ac",
					"reqSigs": 1,
					"type": "pubkeyhash",
					"addresses": [
						"1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE"
					]
				}

```

* 转移-TransB: id(3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517) -> vin scriptSig (解锁保险箱A，拿出资金)


```
			{
				"txid": "b0a0afb65ac08f453b26fa03a40215be653b6d173510d366321019ab8248ea3b",
				"vout": 0,
				"scriptSig": {
					"asm": "304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0[ALL] 04c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5",
					"hex": "47304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0014104c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5"
				},
				"sequence": 4294967295
			}

```

* 下家-TransB: id(3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517) ->vout scriptPubkey (转移到保险箱B，并给B上锁)

```
			{
				"value": 0.00007000,
				"n": 0,
				"scriptPubKey": {
					"asm": "03db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603 OP_CHECKSIG",
					"hex": "2103db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603ac",
					"reqSigs": 1,
					"type": "pubkey",
					"addresses": [
						"1aau2Kgn7xBRWS6gPkYXWiw4cnzyKi7rR"
					]
				}
			}

```

具体怎么理解这两个东东呢？我们还需要一点前置知识。

## 比特币脚本语言系统 scripting language

scriptPubkey以及scriptSig是一种脚本语言。比特币的脚本语言被设计为一种类 Forth 栈语言。拥有成无状态和非图灵完备的性质。无状态性保证了一旦一个交易被区块打包，这个交易就是可用的。图灵非完备性（具体来说，缺少循环和goto 语句）使得比特币的脚本语言更加不灵活和更可预测，从而大大简化了安全模型。

如果大家之前做过汇编开发的话，就会发现这跟汇编的指令码是非常相似的东东。

先来一个在线解析工具:

https://bitcoin-script-debugger.visvirial.com/

再来一个视频讲解：

https://www.youtube.com/watch?v=4qz7XehSBCc

比较简单的教程:

https://davidederosa.com/basic-blockchain-programming/bitcoin-script-language-part-one/

* 额，我知道大部分人跟我一样懒得去翻阅上面这些资料，所以我们简单传送一下：


### 一个最小脚本集

现在想象我们有一台非常简单的计算器，它的CPU只有一个16位的寄存器，以及非常小的内存(520B)；我们需要设计一种语言，实现一些最简单的计算，比如：


```
x = 0x23
x += 0x4b
x *= 0x1e

```

然后转换为类似汇编语言的比较简单的操作码形式, 我们需要以下指令集：


opcode | encoding | 操作码| 操作数(V值) | explained
---|---|---|---|---
SET(V) | `ab` V | `0xab` | 16bits(0x23) | 将V(0x23)载入到寄存器中
ADD(V) | `ac` V | `0xac` | 16bits(0x4b) | 寄存器值+0x4b; `0x23 + 0x4b = 0x6e`
MUL(V) | `ad` V | `0xad` | 16bits(0x1e) | 寄存器值*0x1e; `0x6e * 0x1e = 0x0ce4`


在上面这个表格中，我们定义了三种最简单的操作码：`0xab, 0xac, 0xad`，跟在这三个操作码后面的2个字节就是操作数；将上面的计算步骤用代码表示如下(小端排序):


```
ab 23 00 ac 4b 00 ad 1e 00

```

我们可以实现一个最简单的脚本逻辑，顺序parse这段代码，并转换为相应的操作码，然后进行运算；

我们实现了一个非常迷你的脚本集。


### 栈设计

上面的操作只涉及到了寄存器，但是现实情况中，我们通常要做多个计算步骤，并将临时变量存到内存中，另外会把复杂的程序组织为一个个函数；这种时候，最常见的内存组织方法是什么呢？

没错，就是我们最常用的数据结构：栈(STACK)。

比如下面这个函数:


```
int foo() {

    /* 1 */

    /* 2 */
    uint8_t a = 0x12;
    uint16_t b = 0xa4;
    uint32_t c = 0x2a5e7;

    /* 3 */
    uint32_t d = a + b + c;

    return d;

    /* 4 */
}

```
1. 第一步函数刚刚跳转执行，栈初始化为空。[]
2. 第二步，三个变量`a,b,c`压入栈中(PUSH STACK)

```
[12]
[12, a4 00]
[12, a4 00, e7 a5 02 00]

```
3. 结合我们上面的操作码，计算`a,b,c`的和，并将结果压栈

```
[12, a4 00, e7 a5 02 00, 9d a6 02 00]

```
4. 返回结果，并将栈元素弹出(POP STACK)，恢复到初始状态。

```
[12, a4 00, e7 a5 02 00]
[12, a4 00]
[12]
[]

```

### Script Language

机器码设计了指令的表示方法，栈设计规定了数据的存储方法；将机器码与栈设计结合起来，就是Bitcoin Script Language。它有几个明显的特点：

* 脚本没有循环:这意味着脚本不能无限运行
* 栈空间只有520字节
* 整形常量4字节
* 脚本的内存访问是基于栈的:这意味着脚本中不存在命名变量这种东西，所有的操作码和操作数都表示为栈上的运算；通常，推入的栈项将成为后续操作码的操作数。在脚本的末尾，最上面的堆栈项是返回值。

举个最简单的例子，bitcoin script language支持下面两个操作码：

#### 压栈操作码

opcode | encoding | explained
---|---|---|---
OP_0 | 0x00 | 将0x00压入栈中
OP_1 -- OP_16 | 0x51 -- 0x60 | 将0x01 -- 0x10 压入栈中



> PS: OP_0, OP_1还代表着布尔值False,True


然后下面一段示例脚本代码：


```
54 57 00 60

```
或者直接翻译为:


```
OP_4 OP_7 OP_0 OP_16

```

作用就是将四个值依次压栈，栈状态可以表示为:


```
[]
[04]
[04, 07]
[04, 07, 00]
[04, 07, 00, 10]

```

此时栈顶元素值为0x10，前面我们说了，栈顶元素即返回值，所以这个脚本的返回值为0x10。当然，这个脚本现在就是将四个值压栈，并没有什么实际作用。


#### PUSH DATA操作码

简单的压栈操作码只能压入1个字节的数据，如果我们想以此压入多个字节的数据，需要用到 `PUSH DATA`操作码。


opcode | encoding | L (length) | D (data)
---|---|---|---
OP_PUSHDATA1 | `0x4c` L D | 8bits | L bytes
OP_PUSHDATA2 | `0x4d` L D | 16bits| L bytes
OP_PUSHDATA3 | `0x4e` L D | 32bits| L bytes


* L 代表需要压入的字节长度，它可以有8bits, 16bits，或者32bits，这三个操作码可以最大压入2^8 - 1 = 255字节、2^16 - 1 = 65535字节、2^32字节
* D 代表实际的数据

举个例子:


```
4c 14 11 06 03 55 04 8a
0c 70 3e 63 2e 31 26 30
24 06 6c 95 20 30

```

前面的`0x4c`代表是`OP_PUSHDATA1`操作符，后面的`0x14`代表压入20个字节，然后后面跟着20字节的数据

此时栈状态可以表示为:


```
[11 06 03 55 04 8a 0c 70
 3e 63 2e 31 26 30 24 06
 6c 95 20 30]

```

另外，为了节省空间，还有一个非常取巧的设计:
对于非常短的数据有一种特殊的编码。如果一个操作码位于01到4b之间(包括在内)，它就是一个push数据操作，其中操作码本身就是字节长度:

opcode | encoding | L (length) | D (data)
---|---|---|---
L | L D | 8bits (0x01-0x4b) | L bytes

比如下面的例子:


```
07 8f 49 b2 e2 ec 7c 44

```

最前面的`07`代表着直接将后面7个字节压栈


```
[8f 49 b2 e2 ec 7c 44]

```


#### 算术操作码

算术操作码都是基于栈元素操作的，所以他没有显式的传入参数。


opcode | encoding
---|---
OP_ADD | 0x93
OP_SUB | 0x94

这两个操作符都需要从栈顶一次弹出两个元素作为操作数。

例如:


```
55 59 93 56 94

```

或者直接翻译为:


```
OP_5 OP_9 OP_ADD OP_6 OP_SUB

```

每一步操作的栈状态:


```
[]              # 初始化
[5]             # OP_5
[5, 9]          # OP_9
[14]            # POP; POP; OP_ADD(5, 9)
[14, 6]         # OP_6
[8]             # POP; POP; OP_SUB(14, 6)

```

最后的结果是8

#### 比较操作码

比较用于判断语句，作用比较简单。同样的，它需要从栈顶弹出两个元素来比较。

opcode | encoding
---|---
OP_EQUAL | 0x87
OP_EQUALVERIFY | 0x88

OP_EQUALVERIFY跟OP_EQUAL作用相同，但是比较之后还要执行一个 OP_VERIFY操作。OP_VERIFY检查栈顶元素，如果栈顶元素不为真，就出栈并标记交易无效。

跟之前的算术操作码结合起来的一个例子:


```
02 c3 72 02 03 72 01 c0 93 87

```

翻译为


```
[c3 72] [03 72] [c0] OP_ADD OP_EQUAL

```

执行起来是这样子的：


```
[]                      # 栈初始化
[c3 72]                 # `02 c3 72`代表c3 72两个字节直接入栈
[c3 72, 03 72]          # `02 03 72`代表03 72两个字节直接入栈
[c3 72, 03 72, c0]      # `01 c0`代表c0直接入栈
[c3 72, c3 72]          # 栈顶弹出c000, 0372, 相加得 c3 72
[1]                     # 栈顶弹出c372，c372，比较为真

```

最后这个表达式结果为1。


#### 栈操作码

这个操作码比较特殊，它得作用是直接将栈顶元素复制一份，然后入栈。


opcode | encoding
---|---
OP_DUP | 0x76

例子:


```
04 b9 0c a2 fe 76 87

```

翻译为:


```
[b9 0c a2 fe] OP_DUP OP_EQUAL

```

执行起来是这样子的：


```
[]                          # 栈初始化
[b9 0c a2 fe]               # 04代表后面4个字节压栈
[b9 0c a2 fe, b9 0c a2 fe]  # 复制栈顶4字节然后压栈
[1]                         # 弹出栈顶8字节，比较结果为真

```

可以看出来，如果OP_DUP后面跟着OP_EQUAL，执行结果永远为真。


#### 加解密操作码

这几个操作码是比特币交易验证得核心操作码，也是做事情最多的：


opcode | encoding
---|---
OP_HASH160 | 0xa9
OP_CHECKSIG | 0xac

OP_HASH160 弹出顶部堆栈项，在其上执行sha256=>hash160，然后返回结果。

OP_CHECKSIG 弹出前两个堆栈项，第一个是ECDSA公钥，第二个是der编码的ECDSA签名。之后，如果签名对该公钥有效，则推送OP_TRUE，否则推送OP_FALSE。它是OpenSSL的ECDSA_verify的脚本实现。


##### 有了以上的知识，我们就能深入解析比特币交易加锁解锁的细节啦


## 深入解析scriptPubkey与scriptSig


#### 首先然我们来解析一下TransA的 scritPubkey 加锁脚本


```
76a914650d0497e014e60d4680fce6997d405de264f04288ac

```
			
翻译为

1. 0x76代表OP_DUP
2. 0xa9代笔OP_HASH160
3. 0x14代表后面20个字节`650d0497e014e60d4680fce6997d405de264f042`直接入栈，这20个字节其实是转账地址的pubKeyHash
4. 0x88代表OP
5. 0xac代表OP_EQUALVERIFY

最后翻译为:


```
OP_DUP OP_HASH160 650d0497e014e60d4680fce6997d405de264f042 OP_EQUALVERIFY OP_CHECKSIG

```

再简化一下


```
OP_DUP OP_HASH160 <PubkeyHash> OP_EQUALVERIFY OP_CHECKSIG

```

这段脚本代表 TransA的发起者把一笔钱转入到保险箱后，用这个脚本设置了一把锁，谁能提供另外一个脚本，跟此脚本合并运算后，栈元素全部出栈，并且最后出栈元素为真，那么就视为解锁成功，可以花费这笔钱。

仔细看看，解开这把锁需要我们提供什么信息呢？

1. 首先我们要提供一个公钥，确保这个公钥执行 OP_HASH160操作后，与PubKeyHASH相匹配，其意义就是证明你拥有这个转账地址的公钥
2. 光证明拥有公钥不安全，毕竟如果这个地址之前花费过，公钥就明晃晃暴漏了；所以你还要提供一个对这个脚本的签名，并通过OP_CHECKSIG验证，证明你还拥有和公钥相对的私钥；而私钥只有拥有人才知道，它是永远不会暴露的
3. 同时进行公钥、私钥的验证保证了比特币的安全性，毕竟，即使量子计算机成真，它也需要同时攻破三重保险：

    - 逆向sha256
    - 逆向ripemd160
    - 逆向ECDSA
    
如果能做到这个，那么，全世界的银行、金融、所有的信息系统都不安全了。如果真的到了那个时候，比特币的安全就不值一提了。


#### 那么我们提供的解锁脚本TransB的scriptSig 同样解析一遍看一下


```
47304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0014104c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5

```

解析为:

1.0x47代表后面71个字节入栈，这其实就是签名`Sig`:


```
304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac001

```

2.0x41后面代表65个字节入栈，这是`Pubkey`:


```
04c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5

```

最终简化为


```
<Sig> <PubKey>

```

这就是我们开锁的钥匙！


#### 合并运算

我们把两个脚本来合并运算(把钥匙插进锁孔里)

* scriptPubKey (锁):

`OP_DUP OP_HASH160 <PubkeyHash> OP_EQUALVERIFY OP_CHECKSIG`

* scriptSig (钥匙):

`<Sig> <PubKey>`



```
[]                                                              # 初始化
[Sig]                                                           # 将scriptSig中的sig信息入栈
[Sig, PubKey]                                                   # 将scriptSig中的Pubkey入栈
[Sig, PubKey, OP_DUP]                                           # 将scriptPubKey中的 OP_DUP入栈
[Sig, Pubkey, Pubkey]                                           # 执行OP_DUP，复制栈顶元素PubKey
[Sig, Pubkey, Pubkey, OP_HASH160]                               # 将scriptPubKey中的 OP_HASH160入栈
[Sig, Pubkey, hash160(Pubkey)]                                  # 执行OP_HASH160
[Sig, Pubkey, hash160(Pubkey), PubkeyHash]                      # 将scriptPubKey中的 PubKeyHash入栈
[Sig, Pubkey, hash160(Pubkey), PubkeyHash, OP_EQUALVERIFY]      # 将scriptPubKey中的 OP_QUEALVERIFY入栈
[Sig, Pubkey]                                                   # 检查公钥是否有效，如果有效，出栈
[Sig, Pubkey, OP_CHECKSIG]                                      # 将scriptPubKey中的 OP_CHECKSIG入栈
[1]                                                             # 执行OP_CHECKSIG，用Pubkey检查Sig的有效性；检查通过
[]                                                              # Gooooooooood!! 钥匙合法，开锁成功

```

最后合并运算的结果返回为True。解锁成功。

然后我们用一张语法树解析图再现整个过程：

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20181209/bg1.png)

##### 这就是一笔标准的P2PKH(Pay to Public Key Hash)交易的全解析。


#### Pay to PubKey

既然已经开锁，我们就可以像TransA的scriptPubKey一样，再构造TransB的scriptPubkey，将资金转到新的保险箱中，并重新加锁。

TransB的scriptPubkey 构造为:


```
03db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603 OP_CHECKSIG

```

?? 这怎么跟我们上一笔TransA的scriptPubkey长的不一样？

没错，这笔交易的输出小任性了一把，我们说标准的输出是要求提供一个公钥来验证 Public Key hash值的，但是这笔交易的转移者非常有自信，他说，你直接提供私钥签名就可以花费了，不用那么麻烦了。

这种交易称之为Pay to Pubkey，安全性肯定不如Pay to Public Key Hash交易的；但是因为比较方便，早期有一些交易采用了这种形式，但是现在已经越来越少了；

要解开这把锁，只需要提供签名就好了，更简单。

总结一下这种交易的scriptPubkey加锁脚本以及scriptSig解锁脚本：


```
scriptPubkey: <pubkey> OP_CHECKSIG
scriptSig: <sig>

```

如果你感兴趣的话，自己去找找这笔交易对应的scriptSig吧。

## 一些神奇的操作符

#### OP_CHECKLOCKTIMEVERIFY

也有人把这个操作符称之为OP_CLTV，或者昵称为OP_HODL；什么意思呢？就是这个操作符允许你发送一笔钱给一个地址，并且用OP_HODL指定一个时间，只有过了这个时间之后，才能花费这笔资金！

这个操作符在[BIP65](https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki)中定义，2015-11-30在Bitcoin Core 0.11.2版本中激活。

之前我们介绍过交易中有个locktime字段，功能是类似的；区别在于，locktime交易在指定到达交易时间之前，是不入区块链的，所以如果设置了RBF的话，可以随时取消；

但是OP_HODL是入块的，真正落子无悔!

这个操作符最大的作用，让我来看就是让真正的比特币死忠实现`屯币不动`。死忠们经常说一币一别墅，一币$250K，但是稍微有个风吹草动就卖掉了；如果你对比特币的信心无可匹敌的话，就用`OP_HODL`操作符将自己的币锁定10年吧。

持币10年之后再看比特币兴衰，才是真死忠。


## 小结

这篇文章中我们从最基本的栈脚本操作码讲起，然后一步一步说明了比特币的脚本系统是如何设计、运作的。

最后，我们详细解析了一笔完整的标准Pay to Public Key Hash 交易；看到这里，你已经完全理解了比特币运作的基础；你已经是货真价实的`专家`啦；撒花庆祝~~~

关于比特币的脚本系统，其实最初的时候还是挺有争议的，大家觉得过于复杂，对安全性不利，而实际上历史上确实出现过安全方面的漏洞，后来陆续又禁用了一些操作码；关于这个设计理念，早期中本聪本人曾经做过讲解，这个帖子是早期先驱非常非常有意思的讨论，值得一读:

https://bitcointalk.org/index.php?topic=195.5


说些题外话，其实仔细读读比特币第一版的源码，还有中本聪早期在论坛上发的贴子，很容易就有几个结论：

1. 比特币不是一拍脑袋就蹦出来的，中本聪至少从2006--2007年就已经开始思考整个设计了；并且2008年白皮书发表之前，中本聪基本上已经实现第一版本的代码了
2. 中本聪是密码学方面的大师，他对于各个算法的优点劣势都非常熟悉
3. 中本聪是个编程大师，并且很有可能是个MS流派的码农；他对p2p网络，计算机汇编指令集，跨平台GUI都很熟悉，而且是个实战派；这一点非常重要，也是中本聪和其它理论派科学家的根本不同：他不光有点子，还有能力用代码去实现设想。
4. 这是我的推论哈，代码风格看起来很统一，极大可能中本聪是一个人而不是一个组织；这和文学作品一样的，大家读读代码就很容易感觉出来，这是一个人写的。


当然，除了Pay to public key Hash交易，比特币还支持其它比较复杂的交易类型，用于更丰富的金融场景中（比如合约、公证等等），另外，还有挖矿奖励是怎么来的？这个还没说来。

那么，我们下篇文章再见。



## 工具

最后再增加几个在线调试bitcoin script的工具:

https://webbtc.com/script

https://siminchen.github.io/bitcoinIDE/build/editor.html

#### 引用资料:

https://en.bitcoin.it/wiki/Script

https://davidederosa.com/basic-blockchain-programming/bitcoin-script-language-part-two/

http://www.righto.com/2014/02/bitcoins-hard-way-using-raw-bitcoin.htlm

https://github.com/petertodd/python-bitcoinlib/blob/master/bitcoin/core/script.py

https://medium.com/@thomasmccabe/hodling-bitcoins-with-op-checklocktimeverify-a-step-by-step-guide-to-manually-building-a-bitcoin-ce9476725de8

https://bitcointalk.org/index.php?topic=1250409.0
