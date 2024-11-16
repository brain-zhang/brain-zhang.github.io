---
layout: post
title: "比特币的HD钱包演化-2"
date: 2018-11-02 13:31:50 +0800
comments: true
categories: blockchain
styles: data-table
---

好了，有了上一篇文章的基础，我们可以从零开始完全探究数字货币的地址生成、管理方法；下面的代码均使用Linux Bash shell和Python3来处理；另外需要安装[pycoin](https://github.com/richardkiss/pycoin)这个库。

<!-- more -->

## 生成私钥

一般来说，私钥是个256bit的随机字符。为了演示方便，我们用一个人民大众喜闻乐见的地址生成为例子，私钥选取为 sha256("satoshi")


```
> printf "satoshi"|sha256sum
da2876b3eb31edb4436fa4650673fc6f01f90de2f1793c4ec332b2387b09726f  -

```

得到私钥为`da2876b3eb31edb4436fa4650673fc6f01f90de2f1793c4ec332b2387b09726f`

## 用WIF (Wallet Import Format)表示私钥

我们看到私钥本质上是256bit的数字，他可以用二进制表示，也可以用16进制字符串表示，也可以用Base58Check来表示；为了在不同的钱包中方便的导入导出私钥，也为了方便二维码的生成，比特币采用了名为`WIF`的表示方法，下面列一个表格来说明:


Type | Prefix | Description | Private key
---|---|---|---
Raw | None | 32 bytes binary |  11011010001010000...........
HEX | None | 64 hexadecimal digits | da2876b3eb31edb4436fa4650673fc6f01f90de2f1793c4ec332b2387b09726f
WIF | 5 | Base58Check encoding | 5KUN8s42BCTkQVMTy3oFfqeXE8awVskbDi6XbDMpRnFvHJW9fgk
WIF-compressed | K or L | Base58Check encoding | L4XnHhvLC1b4ag9L2PM9kRicQxUoYT1Q36PQ21YtLNkrAdWZNos6


得到WIF 代码示例:


```
def gen_pubk_from_privk(private_key, compressed=True):
    # private_key = codecs.encode(os.urandom(32), 'hex').decode()
    secret_exponent = int('0x' + private_key, 0)
    print('WIF: ' + encoding.secret_exponent_to_wif(secret_exponent, compressed=compressed))
    public_pair = ecdsa.public_pair_for_secret_exponent(ecdsa.secp256k1.generator_secp256k1, secret_exponent)
    print('public pair:', public_pair)
    return public_pair


```

WIF格式分为非压缩和压缩格式，压缩私钥其实是对非压缩私钥后缀追加了01之后的Base58Check编码，具体生成过程为:

* 压缩私钥: 私钥前缀80+私钥本体+压缩私钥后缀01 + 校验
* 非压缩私钥: 私钥前缀80+私钥本体+校验

和字面意思相相反的是，压缩私钥比非压缩私钥还长。为啥这么折腾呢？这个我们在公钥生成的部分说明。


## 生成公钥

我们之前的文章介绍了，公钥是在椭圆曲线上的一个点，由一对坐标（x，y）组成。公钥通常表示为前缀04紧接着两个256比特的数字。其中一个256比特数字是公钥的x坐标，另一个256比特数字是y坐标。前缀04是用来区分非压缩格式公钥， 压缩格式公钥是以02或者03开头。

下面是由前文中的私钥所生成的公钥，其坐标x和y如下:

* public pair: 

  - x = 89077434373547985693783396961781741114890330080946587550950125758215996319671
  - y = 114001858762817543140175961139571810325965930451644331549950109688554928624341

加上前缀04，完整的公钥为:


```
K = 0489077434373547985693783396961781741114890330080946587550950125758215996319671114001858762817543140175961139571810325965930451644331549950109688554928624341

```


#### 为什么要区分压缩格式和非压缩格式

这是一个历史问题，初版比特币运行时，中本聪没有考虑到一个问题:

一个公钥是一个椭圆曲线上的点(x,y)。而椭圆曲线实际是一个数学方程，曲线上的点实际是该方程的一个解。因此，如果我们知道了公钥的x坐标，就可以通过解方程 `y^2 % p = (x^3 + 7) % p`得到y坐 标。这种方案可以让我们只存储公钥的x坐标，略去y坐标，从而将公钥的大小和存储空间减少了256 bits。如果每笔交易所 需要的字节数减少了近一半，随着时间推移，节省的数据传输和存储空间还是很客观的。

所以后来开发团队推出了压缩公钥，为了跟之前老版本的非压缩公钥相区分，就加上了02和03作为前缀。

那么为什么要加两个前缀(02,03)呢？

因为椭圆曲线加密的公式的左边是y2 ，也就是说y的解是来自于一个平方根，可能是正值也可能是负值。更形象地说，y坐标可能在 x坐标轴的上面或者下面。椭圆曲线图中曲线是对称的，从x轴看就像对称的镜子两面。因此，如果我们略去y坐标，就必须储存y的符号（正值或者负值）。换句话说，对于给定的x值，我们需要知道y值在x轴的上面还是下面，因为它们代表椭圆曲线上不同的点，即不同的公钥。当我们在素数p阶的有限域上使用二进制算术计算椭圆曲线的时候，y坐标可能是奇数或者偶数，分别对应前面所讲的y值的正负符号。因此，为了区分y坐标的两种可能值，我们在生成压缩格式公钥时，如果y是偶数，则使用02作为前缀；如果y是奇数，则使用03作为前缀。这样就可以根据公钥中给定的x值，正确推导出对应的y坐标，从而将公钥解压缩为在椭圆曲线上的完整的点坐标。

总结出来，一个公钥的表现形式可以又两种:

1. 04开头的非压缩公钥: (130位十六进制 2+64+64)
2. 02或03开头的压缩公钥:（66位十六进制 2+64）


这样继续推导，两种表现形式可以推导出两个地址，也就是手握一个私钥，可以推导出两个合法的比特币地址。

这样又间接解释了为什么会有压缩私钥和非压缩私钥两种表现：

* 当中本聪实现第一版比特币客户端钱包的时候，没有考虑到公钥可以压缩，所以采用了最原始直接的办法存储公钥和私钥
* 后来人们发现公钥可以简化存储来节省一部分空间，于是加入了压缩公钥格式，为了跟之前的非压缩公钥区分，引入了前缀
* 同样，使用压缩公钥格式的钱包导入导出私钥时，为了区分，也必须为私钥标明它对应的公钥是否压缩格式，所以也为私钥的表示引入了后缀
* 压缩私钥的意思是，由这个私钥导出的公钥表示方法是压缩的，私钥本身还需要引入一个01作为后缀，长度反而多了一个字节


## 从公钥到比特币地址


得出公钥之后，地址的生成还要经过三重变换， 公钥为K，变换过程如下:

1. 首先计算 A = SHA256(K)
2. 计算 B = RIPEMD160(A)
3. Addr = Base58Check（prefix + B）

#### 为什么要有RIPEMD160(SHA256(K)) 的过程

因为中本聪设计之初充分考虑到了安全性方面的问题，一笔交易广播后，并不是直接把公钥K暴漏在外，如果你不花费这个UTXO，暴漏的只有`RIPEMD160(SHA256(K))`这个值。假如将来有一种计算机的计算能力得到指数级别的提升，有一定可能暴力破解椭圆曲线算法。解决方案就是引入`RIPEMD160(SHA256(K))`的过程，这样要破解一个未花费的UTXO，需要逆向RIPEMD160，SHA256，secp256k1三种不同的算法，即使将来量子计算发展到实用阶段，也很难做到吧。

但是根据比特币交易的设计，一个地址重复使用就会暴露公钥K，所以我们推荐的安全做法就是一笔UTXO花费后就更换地址。这也是所有安全钱包的默认实现方法。

这个设计的唯一的瑕疵，在我看来，就是RIPEMD160将公钥的碰撞空间减小了，由 2^256 减小到了 2^160，当然 2^160 的碰撞空间对于现有计算能力也是个天文数字，我想中本聪没有选择SHA3等算法的原因，应该是充分考虑了散列算法的复杂度和差异度，最后选择的RIPEMD160吧。

#### Base58Check编码

WIF格式和比特币地址都是用Base58Check编码表示的，Base58是Base64基础上发展来的，它具有以下功能:

* 一个任意大小的payload。
* 一组58个字母数字符号，由易于区分的大小写字母组成(不使用0OIl)
* 一个字节的版本/应用程序信息。比特币地址为这个字节使用0x00
* 四个字节（32位）基于SHA256的错误检查代码。此代码可用于自动检测并可能纠正排版错误。
* 保留数据中零开头的额外步骤

创建过程:

1. 获取版本字节和payload字节，并将它们连接在一起（按字节顺序）。

2. 取SHA256(SHA256(步骤1的结果))的前四个字节

3. 将步骤1的结果和步骤2的结果连在一起（按字节顺序）。

4. 处理步骤3的结果 - 一系列字节 - 作为单个大端序号，使用正常的数学步骤（bignumber division）和下面描述的base-58字母表转换为base-58。结果应该被标准化为没有任何前导零（字符'1'）的base-58。

5. 在base58中，值为零的前导字符'1'被保留用于表示整个前导零字节，就像它处于前导位置时一样，没有值作为base-58符号。必要时可以有一个或多个前导'1'来表示一个或多个前导零字节。计算步骤3结果中的前导零字节数（对于旧的比特币地址，至少有一个用于版本/应用程序字节;对于新地址，将永远不会有）。每个前导零字节在最终结果中应由其自己的字符'1'表示。

6. 将步骤5中的1与步骤4 的结果连接起来。这是Base58Check的结果。


最后综合起来，从公钥K到比特币地址完整的示意图如下:

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20181102/bg1.jpg)

`satoshi`作为seed计算出私钥，进而计算出公钥K之后，最终进一步生成地址


```
def genaddress_from_pubk(compressed=True)
    # 首先计算 RIPEMD160(SHA256(K))
    ripemd160 = encoding.public_pair_to_hash160_sec(public_pair, compressed=compressed)
    # 再用Base58Check计算最终地址
    addr = encoding.hash160_sec_to_bitcoin_address(ripemd160)
    return addr

```

因为公钥存在压缩形式和非压缩两种形式，所以完整的结果是:



```
seed: satoshi
sha256 private key: da2876b3eb31edb4436fa4650673fc6f01f90de2f1793c4ec332b2387b09726f

compress address
WIF: L4XnHhvLC1b4ag9L2PM9kRicQxUoYT1Q36PQ21YtLNkrAdWZNos6
hash160: 0a8ba9e453383d4561cbcdda36e5789c2870dd41
Bitcoin address:1xm4vFerV3pSgvBFkyzLgT1Ew3HQYrS1V

uncompress address
WIF: 5KUN8s42BCTkQVMTy3oFfqeXE8awVskbDi6XbDMpRnFvHJW9fgk
hash160: 650d0497e014e60d4680fce6997d405de264f042
Bitcoin address:1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE

```

`satoshi`作为seed生成了两个地址:

`1xm4vFerV3pSgvBFkyzLgT1Ew3HQYrS1V`和`1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE`，这都是两个正在使用的地址哦，到今天为止还有热心人源源不断的为`1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE`转账一些零钱作为中本聪的纪念。你可以将WIF导入钱包，然后运行一个全节点，在bitcoin.conf文件中加入`walletnotify`这个选项，关联一个脚本，当收到比特币时就自动转账到自己的地址，参与这两个地址的抽奖哦。

## 一些Base58Check版本前缀和编码后的结果

看到这里，我们发现Base58Check 编码的过程中，最后一步会引入一个前缀。而在比特币中，除了WIF私钥和地址，大多数需要向用户展示的数据都使用Base58Check编码，理所当然的，引入了不同的前缀来区分不同的信息，下面展示了一些版本前缀和他们对应的Base58格式:


Type | Version prefix | Base58 result prefix
---|---|---
Bitcoin Address | 0x00 | 1
Pay to Script Hash Address | 0x05 | 3
Bitcoin Testnet Address | 0x5F | m or n
Private Key WIF | 0x80 | 5, K or L
BIP-38 Encrypted Private Key | 0x0142 | 6P
BIP-32 Encrypted public Key | 0x0488B21E | xpub

我们最常见的一些地址格式:

* 一个是以`1`打头，这是用途最广泛的交易，用作Pay to public key hash，简称P2PKH交易；它表示的是最简单的、用一对私钥和公钥控制的钱包。例如上面的`1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE`
* 还有一种是`3`打头，用作Pay to Script Hash，简称P2SH。多重签名、SegWit以及一些智能合约（没错，比特币也支持简单的智能合约）通常都采用这种“3”型地址.例如`331jjM5a3HgiDqMuSxeiwTUQFCkM71c5VW`
* 以`2`、`m`或`n`开头的地址非常罕见，仅仅被用于比特币的测试网络。
* 首字符是`5`、`K`或`L`的不是地址，而是WIF（Wallet Import Format）格式的私钥，务必要妥善保管，不可泄漏。

除了我们已经提到的WIF和Bitcoin Address，我们还发现了奇怪的BIP-38和BIP-32，这个需要到解释比特币分层子钱包时候来讲解。

## Segwit

比特币的地址规范定义之后，平稳运行了很长时间；直到2017-08-24，[第一个Segwit block](https://www.reddit.com/r/Bitcoin/comments/6vnqi2/btccom_mines_the_481823rd_block_segwit_is_on_stage/)被挖出；事情有了新变化。

比特币进行Segwit升级之后，地址需要做区分，因为Segwit也可以归类为简单的合约交易，所以在早期钱包还没有足够兼容的时候，Segwit地址都用`3`打头的合约地址。

但是Segwit交易其实是很特殊的，另外后来有了BCH分叉，越来越多的人闹不清其分叉地址搞丢过一些BCH币；后面为了解决Segwit交易的标识，大部分钱包逐渐实现了[BIP-0173规范](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki)；即我们今天可以见到的称之为`bech32`格式的地址。

这类地址统一以`bc`开头，后面接着一个版本号，目前只用了`1`，所以我们可以简单认为这类地址统一以`bc1`开头；比如:`bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj`；

bech32地址使用的字符比当前的地址格式要少， 由42个符号组成，小写字母和大写字母之间不再有区别。

这类地址在Bitcoin Core 0.16版本之后的钱包才支持，Bech32地址本身就与SegWit兼容。这意味着交易不需要额外的空间就能将SegWit放入P2SH地址，所以交易费用比较低，Segwit交易目前也逐渐占到了主网交易量的一半；但直到现在，还有很多交易所的BTC提现不支持这类地址；

详细的计算过程其实和base58大同小异，我们就不啰嗦了，可以自己看规范，或示例代码：

https://github.com/sipa/bech32/blob/master/ref/python/segwit_addr.py


再小小总结一下，目前为止，我们最常见的有三类地址:

1. `1`开头，最常见
2. `3`开头，合约、多重签名、Segwit交易
3. `bc1`开头，segwit交易


## Brain Wallet

好啦，我们上面已经完整的再现了由一个 seed单词 `satoshi`，导出两个比特币地址的过程；你只要记好`satoshi`这个单词，就可以在世界上的任何地方，任何时间，掌管发送给`1xm4vFerV3pSgvBFkyzLgT1Ew3HQYrS1V`和`1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE`这两个地址的比特币了。

你不需要银行账号，不需要密保卡，只需要有个可以联网的地方，就能秘密发送交易啦。将来有了免费的卫星网络的话，我想你都不用登陆互联网，可能在家里屋顶上架个锅，淘宝买些零件天线DIY一个设备，要转帐的时候，只要输入`satoshi`就可以秘密完成数亿美元的汇款，而且丝毫不用担心这个账户被政府查封，世界上也只有你一个人能动用这个账户，真是完美的洗钱逃汇工具！也难怪有人说，比特币是人类历史上第一次用技术手段保证了财产的完全私有权。


这个`satoshi`的seed，就是所谓脑钱包的口令，相对于天书一般的256 bits私钥无疑更好记忆，早期这样的工具非常受欢迎，到现在为止你也可以到这个[在线工具](https://brainwalletx.github.io/) 去重复我们以上推导的所有过程。

但是这个方法有个致命的弱点，他的安全性完全取决于seed这个单词的复杂度，像`satoshi`这样的seed，就像`123456`的密码一样，不用说大家都知道安全度为0啊。

而且你自以为选取生日啊、姓名缩写啊、恋人海誓山盟的话语啊，这些东西作为seed，其实也是非常脆弱的。总有人孜孜不倦的遍历所有可能的seed。这在后期导致了非常多的hack事件。

截至2018-12，我检索区块链，统计公开的比特币地址超过了4亿(不包括bech32有446876234)个，如果有万分之一的地址是由脑钱包生成的话，不安全的地址也超过了4w个，所以后来脑钱包这种方式就不被推荐了。

下面可以列举一些已经公开的seed，这都是我用一些公开语料库随意碰撞出来的，你就知道这种方法的危险性啦：


```
FINAL_CRACK_ADDRESS: hash160:sha256:seed:address:wif-priv
FINAL_CRACK_ADDRESS:0a8ba9e453383d4561cbcdda36e5789c2870dd41:c:sha256:satoshi:1xm4vFerV3pSgvBFkyzLgT1Ew3HQYrS1V:L4XnHhvLC1b4ag9L2PM9kRicQxUoYT1Q36PQ21YtLNkrAdWZNos6
FINAL_CRACK_ADDRESS:650d0497e014e60d4680fce6997d405de264f042:u:sha256:satoshi:1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE:5KUN8s42BCTkQVMTy3oFfqeXE8awVskbDi6XbDMpRnFvHJW9fgk
FINAL_CRACK_ADDRESS:c71e3a0989754d4ffae45a1c6ef8e348539cd83c:u:sha256:satoshinakamoto:1K9qgN3H2wB2v3LwJEBDbRRJ3znHXEQP4Y:5HqE1vZMMLc7jZRF5wZb79QexyCguNeNdaHLdKTGndvLBrCHD31
FINAL_CRACK_ADDRESS:ec42ad7fd54f931274b83f6137379206e458b106:u:sha256:1satoshi:1NYEM85RpgkSofLqDfwjb21o3MD4ibSo49:5JSGPQ2Jw1P5cVi2L8LeuWnMF5H8rLGrPPgVM2XE1cahG1BQDzY
FINAL_CRACK_ADDRESS:fd8d22e02b3a41bc38f69516c43f7ebd6268e16b:u:sha256:satoshi nakamoto:1Q7f2rL2irjpvsKVys5W2cmKJYss82rNCy:5K7EWwEuJu9wPi4q7HmWQ7xgv8GxZ2KqkFbjYMGvTCXmY22oCbr
FINAL_CRACK_ADDRESS:0000d85a71f305a1c907cdc7437c43b2eecc35e5:u:sha256:CHARINA143:11121ioKu4MCB1LLzPF98AVtzFsEg7UYKm:5JhayTrDhzDHqCg2v16Y2gZWi4kWF6BFoZR3MyaaxWtyKHzKJ8d
FINAL_CRACK_ADDRESS:0002439f087ffefb973c5b9bbd52f509984d3cbe:c:sha256:purple99:113iKJcZeRxEYRVcWNgVxmjodPAisDZ45:KxFLoyseSyVtKGXQNkYBajT8EqviQSuH64Y6GE1g6KXuvcFaSrqc
FINAL_CRACK_ADDRESS:00027a0ef2b9295011b10b089c8caf2e69f6b6f7:u:sha256:bridesmaid:113y6FCRm2WHh5Aru2R7ot37wkNDtxqf3:5JsYc8oXiHBJm9rzRPJHaCSYBBx7KCTx5L81rqRMZBArsdZTsan
FINAL_CRACK_ADDRESS:00030fa763130b5310afe68b12204009e60e935c:u:sha256:masturbating:114fh9qiRhubJJDV5rCthFxmGyYeLQ2B6:5J8TgeF9jU3BPRrsCD75Ks4a6aWxgzLKENDSbsLufDTWq7evCQa
FINAL_CRACK_ADDRESS:0005736b486f87e5823909a89eb48dda185d3956:u:sha256:nitro:117XjTn3UdBNjVo3KsB17WRFDDmcW2pPa:5JkUWsPzNEZEvMFwWQjoXCeem5LL6LDcC7K6H1LWiwXFAA9LFo1
FINAL_CRACK_ADDRESS:00080beae5c3a433fbae8ff0b69e705ac3ce5464:u:sha256:resultantly:11Ae5tbiSZ7QJWh4okWJhDKuPfAvk3a13:5KftjbtsSmhy5Y42AYpfEAm4U4vQKP9VhjbS6xtFqBDhUfAGaFj
FINAL_CRACK_ADDRESS:00083c18c738e883ebc1b5ca270569ee8f9f790e:u:sha256:suggestively:11AsAKWdMZj5ScSYRoAQ8xG4J7Y6s7cW9:5JvrusiSgSmCTV7x7f5vgdWUMLjwk153j9UXmNHvRAJ8m7rtsJD
FINAL_CRACK_ADDRESS:000e4d1774a3fc0251e9e6caf0a8617639e80093:u:sha256:dezoxiribonukleinsav:11J8fK9qhgxdQ96ZvvXExkfFvQSPQiPKN:5KSkRxaAbk94wzzzynDNj2bzRFmJZXCrhtYj3iGU9JjUxnRXTYM
FINAL_CRACK_ADDRESS:00135d1c8f99cc657ad1f246bc5051ad03f95d32:u:sha256:Mussolini:11QCR3sk9r4jeyMqCKGEYabGTfjzhgGdZ:5K2x6UanMSevNX7f19oB4to46C3zXoGTUBGVqv8WNtCRwJNGBGC
FINAL_CRACK_ADDRESS:001ed6fae0af0b37126004029defcc4521b300dd:u:sha256:meagerness:11dwnVzCyGoMZcGDndQteWgR9b7FKsJMu:5JKVJhbZWXmHxj2MuttZCDaFk7TC9KBVYjbPRjztP63mmAUV6Vm
FINAL_CRACK_ADDRESS:002607c11a2311825a087f37c95d7816e0491a9d:u:sha256:vertebrate:11nZPfxYPeDm4d4fd93BaFa1BezFRTP6F:5HsBbgzEXZEaeLRCZHs66ho2ekpFEqeAJyyBPe8YyMkCqCHWv6j
...

```


不过我们现在已经掌握到了比特币地址的生成原理，所以如何提高安全性就不用我再啰嗦了，相信你心中已有答案。


## 那些山寨币们

比特币项目是2009-01-03正式开始运行的，之后简单的复制一下比特币的代码，稍作修改就推出的山寨币们数不胜数；这些山寨币第一个要修改的，就是地址格式，以免和比特币地址混淆；

怎么修改呢？注意到前面Base58Check Encode的最后一步了吗？那个时候我们需要引入一个前缀作为地址的区分；得益于比特币这种前瞻性的设计，山寨币们只要改动一下这个前缀就可以了，下面列举一下我所知道的山寨币的实现：

引用自:
https://github.com/walletgeneratornet/WalletGenerator.net



```
name, networkVersion, privateKeyPrefix, WIF_Start, CWIF_Start
"2GIVE",               0x27, 0xa7, "6",    "R"
"42coin",              0x08, 0x88, "5",    "M"
"Acoin",               0x17, 0xe6, "8",    "b"
"AGAcoin",             0x53, 0xd3, "8",    "Y"
"Alphacoin",           0x52, 0xd2, "8",    "Y"
"Alqo",                0x17, 0xc1, "7",    "V"
"Animecoin",           0x17, 0x97, "6",    "P"
"Anoncoin",            0x17, 0x97, "6",    "P"
"Apexcoin",            0x17, 0x97, "6",    "P"
"Auroracoin",          0x17, 0x97, "6",    "T"
"Aquariuscoin",        0x17, 0x97, "6",    "P"
"Axe",                 0x4B, 0xCB, "7",    "X"
"BBQcoin",             0x55, 0xd5, "6",    "T"
"Biblepay",            0x19, 0xb6, "7",    "[TU]"
"Bitcoin",             0x00, 0x80, "5",    "[LK]"
"BitcoinCash",         0x00, 0x80, "5",    "[LK]"
"BitcoinDark",         0x3c, 0xbc, "7",    "U"
"Bitcore",             0x00, 0x80, "5",    "[LK]"
"BitcoinGold",         0x26, 0x80, "5",    "[LK]"
"Bitconnect",          0x12, 0x92, "5",    "N"
"Birdcoin",            0x2f, 0xaf, "6",    "[ST]"
"BitSynq",             0x3f, 0xbf, "7",    "V"
"BitZeny",             0x51, 0x80, "5",    "[LK]"
"Blackcoin",           0x19, 0x99, "6",    "P"
"BlackJack",           0x15, 0x95, "[56]", "P"
"BlockNet",            0x1a, 0x9a, "6",    "P"
"BolivarCoin",         0x55, 0xd5, "8",    "Y"
"BoxyCoin",            0x4b, 0xcb, "7",    "X"
"BunnyCoin",           0x1a, 0x9a, "6",    "P"
"Cagecoin",            0x1f, 0x9f, "6",    "Q"
"CampusCoin",          0x1c, 0x9c, "6",    "Q"
"CanadaeCoin",         0x1c, 0x9c, "6",    "Q"
"CannabisCoin",        0x1c, 0x9c, "6",    "Q"
"Capricoin",           0x1c, 0x9c, "6",    "Q"
"CassubianDetk",       0x1e, 0x9e, "6",    "Q"
"CashCoin",            0x22, 0xa2, "6",    "[QR]"
"Catcoin",             0x15, 0x95, "[56]", "P"
"ChainCoin",           0x1c, 0x9c, "6",    "Q"
"ColossusCoinXT",      0x1e, 0xd4, "5",    "[LK]"
"Condensate",          0x3c, 0xbc, "7",    "U"
"Copico",              0x1c, 0x90, "5",    "N"
"CopperCoin",          0x1c, 0x9c, "6",    "Q"
"Corgicoin",           0x1c, 0x9c, "6",    "Q"
"CryptoBullion",       0x0b, 0x8b, "5",    "M"
"CryptoClub",          0x23, 0xa3, "6",    "R"
"Cryptoescudo",        0x1c, 0x9c, "6",    "Q"
"Cryptonite",          0x1c, 0x80, "5",    "[LK]"
"CryptoWisdomCoin",    0x49, 0x87, "5",    "[LM]"
"C2coin",              0x1c, 0x9c, "6",    "Q"
"Dash",                0x4c, 0xcc, "7",    "X"
"DeafDollars",         0x30, 0xb0, "6",    "T"
"DeepOnion",           0x1f, 0x9f, "6",    "Q"
"Deutsche eMark",      0x35, 0xb5, "7",    "T"
"Devcoin",             0x00, 0x80, "5",    "[LK]"
"DigiByte",            0x1e, 0x9e, "6",    "Q"
"Digitalcoin",         0x1e, 0x9e, "6",    "Q"
"Dimecoin",            0x0f, 0x8f, "5",    "N"
"DNotes",              0x1f, 0x9f, "6",    "Q"
"Dogecoin",            0x1e, 0x9e, "6",    "Q"
"DogecoinDark",        0x1e, 0x9e, "6",    "Q"
"eGulden",             0x30, 0xb0, "6",    "T"
"eKrona",              0x2d, 0xad, "6",    "S"
"ELECTRA",             0x21, 0xa1, "6",    "Q"
"Ember",               0x5c, 0x32, "2",    "8"
"Emerald",             0x22, 0xa2, "6",    "[QR]"
"Emercoin",            0x21, 0x80, "5",    "[LK]"
"EnergyCoin",          0x5c, 0xdc, "8",    "Z"
"Espers",              0x21, 0x90, "5",    "N"
"Fastcoin",            0x60, 0xe0, "8",    "a"
"Feathercoin",         0x0e, 0x8e, "5",    "N"
"Fedoracoin",          0x21, 0x80, "5",    "[KL]"
"Fibre",               0x23, 0xa3, "6",    "R"
"Florincoin",          0x23, 0xb0, "6",    "T"
"Flurbo",              0x23, 0x30, "6",    "8"
"Fluttercoin",         0x23, 0xa3, "6",    "R"
"FrazCoin",            0x23, 0xA3, "6",    "R"
"Freicoin",            0x00, 0x80, "5",    "[LK]"
"FUDcoin",             0x23, 0xa3, "6",    "R"
"Fuelcoin",            0x24, 0x80, "5",    "[KL]"
"Fujicoin",            0x24, 0xa4, "6",    "R"
"GabenCoin",           0x10, 0x90, "5",    "N"
"Garlicoin",           0x26, 0xb0, "6",    "T"
"GlobalBoost",         0x26, 0xa6, "6",    "R"
"Goodcoin",            0x26, 0xa6, "6",    "R"
"GridcoinResearch",    0x3e, 0xbe, "7",    "V"
"Gulden",              0x26, 0xa6, "6",    "R"
"Guncoin",             0x27, 0xa7, "6",    "R"
"HamRadioCoin",        0x00, 0x80, "5",    "LK"
"HFRcoin",             0x10, 0x90, "5",    "N"
"HOdlcoin",            0x28, 0xa8, "5",    "[LK]"
"HTMLCoin",            0x29, 0xa9, "6",    "S"
"HyperStake",          0x75, 0xf5, "9",    "d"
"ImperiumCoin",        0x30, 0xb0, "6",    "T"
"IncaKoin",            0x35, 0xb5, "7",    "T"
"IncognitoCoin",       0x00, 0x80, "5",    "LK"
"Influxcoin",          0x66, 0xe6, "8",    "b"
"Innox",               0x4b, 0xcb, "7",    "X"
"IridiumCoin",         0x30, 0xb0, "6",    "T"
"iCash",               0x66, 0xcc, "7",    "X"
"iXcoin",              0x8a, 0x80, "5",    "[LK]"
"Judgecoin",           0x2b, 0xab, "6",    "S"
"Jumbucks",            0x2b, 0xab, "6",    "S"
"KHcoin",              0x30, 0xb0, "6",    "T"
"KittehCoin",          0x2d, 0xad, "6",    "S"
"Lanacoin",            0x30, 0xb0, "6",    "T"
"Latium",              0x17, 0x80, "5",    "[LK]"
"LBRY Credits",        0x55, 0x80, "5",    "[LK]"
"Litecoin",            0x30, 0xb0, "6",    "T"
"LiteDoge",            0x5a, 0xab, "6",    "S"
"LoMoCoin",            0x30, 0xb0, "6",    "T"
"MadbyteCoin",         0x32, 0x6e, "4",    "H"
"MagicInternetMoney",  0x30, 0xb0, "6",    "T"
"Magicoin",            0x14, 0x94, "5",    "[NP]"
"Marscoin",            0x32, 0xb2, "6",    "T"
"MarteXcoin",          0x32, 0xb2, "6",    "T"
"MasterDoge",          0x33, 0x8b, "5",    "M"
"Mazacoin",            0x32, 0xe0, "8",    "a"
"Megacoin",            0x32, 0xb2, "6",    "T"
"MintCoin",            0x33, 0xb3, "[67]", "T"
"MobiusCoin",          0x00, 0x80, "5",    "[LK]"
"MonetaryUnit",        0x10, 0x7e, "5",    "K"
"Monocle",             0x32, 0xb2, "6",    "T"
"MoonCoin",            0x03, 0x83, "5",    "L"
"Myriadcoin",          0x32, 0xb2, "6",    "T"
"NameCoin",            0x34, 0x80, "5",    "[LK]"
"Navcoin",             0x35, 0x96, "6",    "P"
"NeedleCoin",          0x35, 0xb5, "7",    "T"
"NEETCOIN",            0x35, 0xb5, "7",    "T"
"NYC",                 0x3c, 0xbc, "7",    "U"
"Neoscoin",            0x35, 0xb1, "6",    "T"
"Nevacoin",            0x35, 0xb1, "6",    "T"
"Novacoin",            0x08, 0x88, "5",    "M"
"Nubits",              0x19, 0xbf, "7",    "V"
"Nyancoin",            0x2d, 0xad, "6",    "S"
"Ocupy",               0x73, 0xf3, "9",    "[cd]"
"Omnicoin",            0x73, 0xf3, "9",    "[cd]"
"Onyxcoin",            0x73, 0xf3, "9",    "[cd]"
"PacCoin",             0x18, 0x98, "6",    "P"
"Particl",             0x38, 0x6c, "4",    "[HG]"
"Paycoin",             0x37, 0xb7, "7",    "U"
"Pandacoin",           0x37, 0xb7, "7",    "U"
"ParkByte",            0x37, 0xb7, "7",    "U"
"Peercoin",            0x37, 0xb7, "7",    "U"
"Pesetacoin",          0x2f, 0xaf, "6",    "[ST]"
"PHCoin",              0x37, 0xb7, "7",    "U"
"PhoenixCoin",         0x38, 0xb8, "7",    "U"
"PiggyCoin",           0x76, 0xf6, "9",    "d"
"Pinkcoin",            0x3,  0x83, "[RQP]","L"
"PIVX",                0x1e, 0xd4, "8",    "Y"
"Peercoin",            0x37, 0xb7, "7",    "U"
"Potcoin",             0x37, 0xb7, "7",    "U"
"Primecoin",           0x17, 0x97, "6",    "P"
"ProsperCoinClassic",  0x3a, 0xba, "7",    "Q"
"Quark",               0x3a, 0xba, "7",    "U"
"Qubitcoin",           0x26, 0xe0, "8",    "a"
"Reddcoin",            0x3d, 0xbd, "7",    "[UV]"
"Riecoin",             0x3c, 0x80, "5",    "[LK]"
"Rimbit",              0x3c, 0xbc, "7",    "U"
"ROIcoin",             0x3c, 0x80, "5",    "[LK]"
"Rubycoin",            0x3c, 0xbc, "7",    "U"
"Rupaya",              0x3c, 0xbc, "7",    "U"
"Sambacoin",           0x3e, 0xbe, "7",    "V"
"SecKCoin",            0x3f, 0xbf, "7",    "V"
"SibCoin",             0x3f, 0x80, "5",    "[LK]"
"SixEleven",           0x34, 0x80, "5",    "[LK]"
"SmileyCoin",          0x19, 0x99, "6",    "P"
"SongCoin",            0x3f, 0xbf, "7",    "V"
"SpreadCoin",          0x3f, 0xbf, "7",    "V"
"StealthCoin",         0x3e, 0xbe, "7",    "V"
"Stratis",             0x3f, 0xbf, "7",    "V"
"SwagBucks",           0x3f, 0x99, "6",    "P"
"Syscoin",             0x00, 0x80, "5",    "[LK]"
"Tajcoin",             0x41, 0x6f, "6",    "H"
"Terracoin",           0x00, 0x80, "5",    "[LK]"
"Titcoin",             0x00, 0x80, "5",    "[LK]"
"TittieCoin",          0x41, 0xc1, "7",    "V"
"Topcoin",             0x42, 0xc2, "7",    "V"
"TransferCoin",        0x42, 0x99, "6",    "P"
"TreasureHuntCoin",    0x32, 0xb2, "6",    "T"
"TrezarCoin",          0x42, 0xC2, "7",    "V"
"Unobtanium",          0x82, 0xe0, "8",    "a"
"USDe",                0x26, 0xa6, "6",    "R"
"Vcash",               0x47, 0xc7, "7",    "W"
"Versioncoin",         0x46, 0xc6, "7",    "W"
"VergeCoin",           0x1e, 0x9e, "6",    "Q"
"Vertcoin",            0x47, 0x80, "5",    "[LK]"
"Viacoin",             0x47, 0xc7, "7",    "W"
"VikingCoin",          0x46, 0x56, "3",    "D"
"W2Coin",              0x49, 0xc9, "7",    "W"
"WACoins",             0x49, 0xc9, "7",    "W"
"WankCoin",            0x00, 0x80, "5",    "[LK]"
"WeAreSatoshiCoin",    0x87, 0x97, "6",    "P"
"WorldCoin",           0x49, 0xc9, "7",    "W"
"XP",                  0x4b, 0xcb, "7",    "X"
"Yenten",              0x4e, 0x7b, "5",    "K"
"Zcash",        [0x1c,0xb8], 0x80, "5",    "[LK]"
"Zetacoin",            0x50, 0xE0, "8",    "a"
"Testnet Bitcoin",     0x6f, 0xef, "9",    "c"
"Testnet Dogecoin",    0x71, 0xf1, "9",    "c"
"Testnet MonetaryUnit",0x26, 0x40, "3",    "A"
"Testnet PIVX",        0x8b, 0xef, "9",    "c"
"Testnet WACoins",     0x51, 0xd1, "8",    "[XY]"


```

哈哈，洋洋大观啊。这也说明了folk一个山寨币的成本是如何的低；然后有了以太坊的ERC20之后，发一个新币的成本简直低到令人发指，也无怪乎场子里面骗子横行了。

## 以太坊的地址生成

Ethereum项目是不走寻常路的，他作为比特币之后最具创新性的后辈，地址设计反而简单的多。

直到生成公钥这一步，以太坊和比特币都是一致的，采用了secp256k1算法，只是最后的地址生成以太坊很简洁，直接Keccak256 hash，然后取最后的40位16进制字符得到的。

为什么比特币实现复杂呢？这是因为比特币的交易是以UTXO为核心的，每个UTXO包含其所有者及价值信息，系统中的每一笔的交易由若干UTXO输入和若干UTXO输出组成。UTXO无法只提取部分，每次必须完整的使用，这有点像我们生活现实中的现金。比特币系统中，一个用户的“余额”是该用户的私钥能够有效签名的所有UTXO的总和。要深刻的理解这一点，还需要我们了解了比特币的交易数据构成之后才能探讨。我们后面会写文章解释这一点啦。

而以太坊采用了与比特币不同的实现方式——账户，类似我们生活中的银行卡。以账户为核心的设计比较节省空间,而且以太坊的block组织更为精巧。另外，以太坊的设计目标和比特币是不同的：

* 首先以太坊的账户除了普通的收发币的账户(俗称外部账户EOA)，还有合约账户，合约账户需要一个固定的地址，不然每次调用合约都会很麻烦；这样就要求以太坊的合约账户不像比特币交易那样频繁的更换地址；
* 他并不执着于强迫用户去注意隐私问题，以太坊的态度是，如果用户注重隐私问题，你就自己搞定；你需要通过合约中的签名数据包协议来建立一个加密“混合器”进行加密。
* 总之以太坊因为要实现的目标更为宏大，他的设计理念是根据最初的用户都是一群Geek们来建立的；Geek们最喜欢啥？就是不要过度设计，让我来自己搞定

所以在以太坊系统中，账户是一个20字节的地址，他关联的信息包含四个部分：

1. 随机数，用于确定每笔交易只能被处理一次的计数器

2. 账户目前的以太币余额

3. 账户的合约代码，如果有的话

4. 账户的存储（默认为空）


可以采用[pyethereum](https://github.com/ethereum/pyethereum)这个库，用以下代码模拟以太坊地址的生成:


```
# -*- coding: utf-8 -*-

"""doctopt ethereum address generate tools

Usage:
  genaddr.py p2addr         <private>
  genaddr.py word2addr      <word>

Options:
  -h --help                                             Show this screen.
  --version                                             Show version.

Example:

    genaddr.py p2addr 6bd3b27c591                                         # gen address from private 0x6bd3b27c591=>1PiFuqGpG8yGM5v6rNHWS3TjsG6awgEGA1
    genaddr.py word2addr 'Money is the root of all evil.'                 # gen address from private wordlist

"""

from docopt import docopt

import os
import sys
from ethereum import utils


if __name__ == '__main__':
    arguments = docopt(__doc__, version='1.0')

    if arguments['p2addr']:
        private_key = bytes.fromhex(arguments['<private>'])
        passpharse = b'unknown'

    elif arguments['word2addr']:
        passpharse = arguments['<word>'].encode('utf-8')
        private_key = utils.sha3(passpharse)

    raw_address = utils.privtoaddr(private_key)
    account_address = utils.checksum_encode(raw_address)
    print("word:{}:private:{}:address:{}".format(passpharse.decode('utf-8'), private_key.hex(), account_address))
    

```



```
> python genaddr.py word2addr 'hello'

word:hello:private:1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8:address:0x5ccfa55C29F0522f062E3C15004E35a69dD45F6B

```

以太坊账户方式的一个弱点是：为了阻止重放攻击，每笔交易必须有nonce。这就使得账户需要跟踪nonce的使用情况。而且，不再使用的账户，无法从账户状态中移除。

关于重放攻击，我们会在后面说明。

## 重放攻击

在网络中重放攻击是一种很常见的hack方式，关于相关攻防有足够丰富的案例；但是在区块链历史上却是一个悲伤的故事；在此我们用一点点篇幅回忆一下区块链上第一次大规模的重放攻击(replay Attack)。


#### 缘起

众所周知，以太坊作为`智能合约`的首创者，在区块链技术史上是继比特币之后最大的创新。在V神于2015-07-30正式推出运行后，立即吸引了众多Geek来探究如何实现白皮书中所说的去中心化程序。其中最受关注的就是2016-04-30日开始募资的[The DAO](https://etherscan.io/address/0xbb9bc244d798123fde783fcc1c72d3bb8c189413)项目。

关于这个项目的始末，实在是槽点满满。即使已经两年后的今天，估计你去搜索这起著名的事件，非码农人士也很难搞明白。简而言之，就是`The DAO`作为一个去中心化的项目基金会开始募资，令人觉得神奇的是，这个项目背后没有一个控制人！即使这个项目筹到一大笔钱，也没有一个人有权利单独动用它，只能所有投资人投票才能决定资金的使用，这是写在区块链代码上的铁律，这就是去中心化的魅力！

但是一个没有控制人，没有开发目标，拿到了钱也不知道今后要干啥的项目组织，说要募资了，然后人们纷纷掏钱买股权，是不是很神奇！

咱们说传销还得有个愿景呢！但是当时`去中心化程序`的概念横空出世，官网页面美轮美奂，诸多`专家`纷纷发表晦涩难懂的高大上文章齐赞`The DAO`的历史意义，就在那种巨大的泡沫环境中，人们害怕的是错过发财的上车机会，于是根本搞不明白这是个什么东西，就慷慨解囊。

你可能觉得好笑，可是看看今天，那些所谓的高大上的区块链项目，所谓的伟大愿景，那些山寨币，那些要颠覆这颠覆那的各路神仙，和当时何其相似！熙熙攘攘的投资人群中，有几人能花时间去搞明白比特币和以太坊的白皮书？

所谓的区块链技术的发展，充斥着贪婪和诈骗。就和人性一样。

#### 崩溃

同样，人类的愚蠢也是不变的，贪婪之下，BUG是无法避免的。

截至2016-05-15，`The DAO`项目的合约募集了大约当时价值约1.5亿美元Ether，占当时Ether发行总量的15%。讽刺的是，这个项目募集了巨大的金额，却没有一个像样的专家去做一个合约代码安全审计！

终于，THE DAO创始人之一Stephan Tual发现其合约代码有部分缺陷，他于6月12日宣布，他们发现了软件中存在的“递归调用漏洞”问题，不过对DAO资金来说则不会出现风险。讽刺的是还是没有多少人注意到这个问题。

2016-06-17，一名黑客在编码上发现了真正的漏洞，使得他可以从`The Dao`上抽走资金。在攻击的头几个小时，360万的Ether被转出，在当时价值相当于七千万美元。当时引起的混乱可想而知，社区采用紧急措施冻结了所有的币，但是只要以太坊的根基代码不变，就无法阻止黑客取现这些财富。

你可以想象当时那些投资人的反应，有人气急败坏要求以太坊开发团队立即采取措施，作废黑客的攻击行为，回退区块链并退回所有投资人的Ether。

而真正的区块链信徒认为`代码即正义、代码即法律`，传统世界中的法律不能应用到cyberpunk世界中，即使是黑客的盗窃行为，也理应收到这种正义保护！回退作废Block的行为其实就是否认区块链的技术意义，它会毁灭以太坊项目。

你可以想象，当你损失了几十万美元，对面的一群码农却做出这种`奇谈怪论`，肯定是想砍人的心都有了。当时的各路利益纠葛者吵了一个翻天覆地。甚至黑客本人也跳出来发表了一通公开信，先为自己的盗窃行为辩护一番，然后承诺只要社区不回退，就会返还一部分金额。整个事件好一场精彩大戏。

#### 分裂

经历了无休止的利益、法律、技术等等辩论后，以太坊社区分裂了。争论的结果就是诞生了ETH Classic (即ETC)项目；一批坚持`代码即正义`者分裂出来创造了ETH Classic 网络，这个项目称自己才是真正的以太坊，并承认黑客的攻击行为且继续将这条链运行下去。而现在仍旧运行的Ethereum网络保护了投资者的利益，做出了妥协；

这个分叉开启于Ethereum网络Block编号为[1192000](https://etherscan.io/block/1192000)区块。

这是世界上第一次公开的人为的区块链分叉事件。但是好戏才刚刚开始。


#### 重放攻击

以太坊硬分叉出现了ETH和ETC两条链，两条链上的交易数据结构是完全一样的，因此一笔交易在ETH上是有效的， 那它在ETC上同样会被接受，反之亦然。 因为当时所有人都认为ETC将不会再存在，所以分叉前没人意识到两条链会产生相互重放问题。 后来还有许多矿工继续在维持ETC链时， 大家发现在ETH链上的交易拿到ETC链继续重放（广播）仍然是有效的。

因为没经验，以太坊分叉时几乎所有交易所也都没意识到这个问题，更没有提前做ETH和ETC分离， 这时候只要有人从交易所提取ETH币，就有可能得到同等数量的ETC币。许多人利用这个漏洞，不断在交易所充币和提币（ETH）， 从而获取额外的ETC。 当时云币、BTC-E等交易所发布说自己被重放攻击了，被骗取了几乎所有ETC。“重放攻击”也就此闻名于币圈。


解决这个问题也很简单，或者就是两边的原始交易数据要有所区别:

* 或者地址前缀做一下改动
* 或者交易数据签名增加一个标志

因为以太坊地址没有像比特币一样的前缀，ETC和ETH社区经过讨论，简单的提出了[EIP-155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md) 作为解决方案。简而言之，就是判断分叉的区块编号，引入一个CHAIN ID新值来解决这个问题。

耐人寻味的是，Ethereum团队此时对于ETC分叉的态度是支持的。就像中本聪早期提到的那样，没有一个人可以集权控制一条链，算力说话。因此ETC活了下来。也因为以太坊的创始人Vitalik Buterin是个非常年轻的天才，整个开发团队洋溢着一种骑士精神;他们对于自由竞争出生的ETC非常包容，不管将来结果如何，我认为这种态度是非常了不起的。

当然，个人感情的说一下。此事说明了投资所谓的区块链项目，究竟有多大的风险！以太坊基础代码有许多人审核，有一定的安全保证，但是形形色色的智能合约就不好说了。后来像DAO一样的hack事件数不胜数！

我得说，当你想要投资一个所谓`未来项目`时，除了你自己的知识和判断，没有任何一个人是可信的！我是说，只能靠自己，其他任何人，甚至创始者的意见也不可信。

## Bitcoin Cash地址生成

关于Bitcoin Cash的诞生，其过程之离奇曲折，胜过ETH分叉百倍。这是一个比最精彩的侦探小说还要反转反转再反转的故事。

不过我们就不要讲故事了，总之Bitcoin Cash分叉诞生后，为了和传统的Bitcoin地址相区别，自己又做了一下改动。

快速看看BCH新老地址的对比：

1. 新地址是和老地址一一对应的，它们对应了同一个私钥，只是换了种写法

2. 新地址可以发送余额给老地址，老地址可以发送余额到新地址

3. 新地址是大小写不敏感的，可以全部转成大写，也可以全部转成小写，优先小写格式，同一地址不能大小写混用

4. 新地址的前缀可写可不写，老地址没有前缀，通过首字符来标识类型

5. 新地址用base32编码，老地址用base58编码

官方文档描述参见[这里](https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/cashaddr.md)，让我们从seed `satoshi` 生成一个bitcoin cash 地址演示一遍。

#### 规范

新的bitcoin cash地址是由：

* 能够表示该地址有效的网络的前缀，一般为主网(bitcoincash)、测试网(bchtest)、回归测试网(bchreg)三种。
* 一个分隔符：`:`
* 一个base32编码的payload，表示这个地址的目的地和包含的checksum（校验和）。

#### Payload

payload是base32编码的数据流，由三个元素组成:

* 指示地址字节的版本类型

共8bits, 1bit(0) + 4bits (地址类型：Type bits) + 3bits (hash长度：Size bits)


Type bits (二进制) | 地址类型 
---|---
0000 | P2PKH
1000 | P2SH
0000 | P2PKH-TESTNET
1000 | P2SH-TESTNET


Size bits (二进制) | 代表hash长度
---|---
000 | 160
001 | 192
010 | 224
011 | 256
100 | 320
101 | 384
110 | 448
111 | 512


* 一个hash值

hash含义取决于版本字段。它是表示数据的hash，即P2KH的pubkey hash和P2SH的reedemScript哈希。这个可以直接从BTC地址里面推出，这个hash值导出后需要用40Bits的BCH码来表示，这样做之后，地址大小写不敏感。

* 一个40字节的校验和

这个校验和的计算比较繁琐，它是在GF（2 ^ 5）上定义的40bits的BCH码，校验和根据以下代码计算：


```
uint64_t PolyMod(const data &v) {
    uint64_t c = 1;
    for (uint8_t d : v) {
        uint8_t c0 = c >> 35;
        c = ((c & 0x07ffffffff) << 5) ^ d;
        
        if (c0 & 0x01) c ^= 0x98f2bc8e61;
        if (c0 & 0x02) c ^= 0x79b76d99e2;
        if (c0 & 0x04) c ^= 0xf33e5fb3c4;
        if (c0 & 0x08) c ^= 0xae2eabe2a8;
        if (c0 & 0x10) c ^= 0x1e4f43e470;
    }
    
    return c ^ 1;
}

```
具体的规则可以详细参考[这里](https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/cashaddr.md)。


#### 地址转换生成

* 1.取`satoshi` 生成的非压缩地址`1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE`
* 2.这个地址是一个主网地址，前缀为`bitcoincash:xxxxx`
* 3.这个地址类型为`P2PKH`，version_bits为0000
* 4.`1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE`进行base58 Decode，去掉末尾的4字节checksum，得到的hash值用list表示

```
payload = [101, 13, 4, 151, 224, 20, 230, 13, 70, 128, 252, 230, 153, 125, 64, 93, 226, 100, 240, 66]

```
* 5.加入version前缀

```
payload = [0, 101, 13, 4, 151, 224, 20, 230, 13, 70, 128, 252, 230, 153, 125, 64, 93, 226, 100, 240, 66]

```
* 6.将hash进行8bits->5bits BCH码的转换

```
payload = [0, 1, 18, 16, 26, 1, 4, 23, 28, 0, 10, 14, 12, 3, 10, 6, 16, 3, 30, 14, 13, 6, 11, 29, 8, 1, 14, 30, 4, 25, 7, 16, 8, 8]

```
* 7.计算校验和

```
checksum=[24, 25, 19, 1, 12, 3, 18, 8]

```
* 8.对payload + checksum进行base32编码，得到`qpjs6pyhuq2wvr2xsr7wdxtagpw7ye8sggcenpvrjg`
* 9.加入前缀`bitcoincash:`，组合得到最后地址`bitcoincash:qpjs6pyhuq2wvr2xsr7wdxtagpw7ye8sggcenpvrjg`

有许多在线转换工具可以验证，比如:

https://bch.btc.com/tools/address-converter



## 总结

以上长篇大论了比特币系统的地址是如何生成的，当然我们也略过了许多细节，比如钱包如何加salt，如何加passphrase等等，这些直接去读BIP 规范更为精确；但是一个完整的钱包，可不仅仅是要解决地址生成这个问题，还要能方便的管理私钥。

在比特币早期，私钥的管理是非常粗暴的，就是每次创建新钱包时，系统自动随机生成100个私钥，然后随着用户交易增多用光之后，再生成100个私钥；钱包文件就是一个二进制文件，即使加了密码保护，也很容易暴力破解泄密；

这导致了无穷多的hack事件；不管你信不信，初期很多从事比特币交易的网站，其wallet.dat文件就明晃晃的放在服务器上，管理员粗心大意，完全可以形容为 `没头脑+不高兴`，很多人连个最基本的密码保护也不设置；另外也发生过很多悲剧的`rm -rf`事件，我认为由于这样的失误导致的比特币丢失至少在100w+ 币的级别；换算今天的汇率，你能相信有个银行将数亿美元现金的保险柜不加锁，明晃晃的摆在大堂上摆阔吗？

在一连串的悲剧事件中(具体是哪些悲剧可以写一本书哦)，作为登峰造极者，mtgox当之无愧！ 80多万个比特币的丢失，史上独一份。这个交易所的老板也是心大，80w+币的钱包密码也不设置一个，就在那里任由黑客予取予求；还不是一天两天哦，是持续好几周的hack事件！

mtgox是比特币历史上巨大的迷雾，他不光牵扯到许多比特币的早期玩家，还有BTC-E, FBI牵涉其中，我认为这是仅次于`中本聪到底何方神圣`的谜题。所幸法胖还活着，我希望有生之年能读到这个事件的完整披露。

好了，假如你是一个交易所的老板，你会很快发现自己面临着以下问题：

* 不需要给每个用户的账户都建立一个钱包文件，我希望能有一个总的账户管理方案
* 可能交易所有1000个大户，你希望他们的钱包是冷存储的，提币的时候他们可以耐心等一段时间，但是剩下的100000个普通用户的账户就要存放到一个热钱包上，只留有部分资产来应付流动性
* 有很多部门需要批准获取一些资金，比如研发要用来做测试，市场部门要用来搞活动等等
* 最后，私钥最好只能由少数人，最好只有我本人来掌握，不然私钥的传播过程中，随便一个人就能让你万劫不复
* 我如果有一些合伙人的话，肯定也希望能掌管一部分资金
* 如果有突发情况，我能迅速把公司账上所有的币都转移到另外一个安全的账户上，这有可能是要迅速完成上万笔的交易转移
* 最后，我希望所有的交易，签署和广播是在不同的机器上进行的，存有私钥的机器不能联网，这台机器签名完毕后，调用远端的服务端广播交易，这样完全实现钱包的冷隔离


好啦，假如我们现在只有前面那种一个wallet.dat钱包的管理方案，要怎么做呢？

很明显的，这种管理太粗糙了。社区们经过不断的探索，提出了BIP-32，BIP-39，BIP-44等规范，以绝妙的办法解决了这些问题。这就是比特币HD钱包的由来。同时这些规范不仅仅适用于比特币系统，还适用于所有的电子货币方案，也许今后，你可以同时在一个钱包里管理你的ETH, BTC, 支付宝余额等等~~~


那到底要怎么做呢？

我们已经探索了这么远，估计你也不耐烦了，但是我们还要说，这还早的很呢！那么下次文章再见。
