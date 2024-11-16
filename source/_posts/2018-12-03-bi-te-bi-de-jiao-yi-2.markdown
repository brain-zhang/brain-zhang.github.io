---
layout: post
title: "比特币的交易-2"
date: 2018-12-03 18:06:46 +0800
comments: true
categories: blockchain
---
之前的文章我们说过，比特币的所有交易抽象成了UTXO的转移。所谓转移，可以这么理解：

* 有M个UTXO作为输入 (M >= 0)
* 有N个UTXO作为输出 (N > 0)
* 输入的UTXO总额==输出的UTXO总额
* 输入的UTXO来源于支付方控制的私钥账户
* 输出的UTXO流向收款方的公钥地址

那么具体是怎么转移的？怎样手工的构造一笔交易呢？我们就在这篇文章里面详细的演示一遍。

首先科普一下常见的交易类型:

<!-- more -->

#### Generation TX

这种交易我们称之为是产量交易(Generation TX)，即矿工挖出一个新的Block时，系统允许这个矿工在块头构造一笔奖励自己的交易，这笔奖励金额被称之为Coinbase奖励，最初一个block挖出的奖励是50BTC，后来就是我们大家所熟知的四年减半原则啦。这样大家明白比特币整个账本里面的初始资金是怎么来的啦。就是系统通过Generation TX向矿工发放奖励产生的BTC。

矿工们计算随机数，竞争打包Generation TX的权力，就是挖矿。具体的细节我们会在以后的文章中介绍。

现在每笔Generation TX的奖励金额是12.5BTC，预计下个减半周期在2020年年中。

注意：Generation TX中的BTC是无中生有的，所以只有输出的UTXO，没有输入的UTXO。

PS:Coinbase作为一个很经典的技术名词，其`coinbase.com`域名被现在美国著名的交易所coinbase Pro 注册持有。


#### Script Hash TX

也被称为P2SH（Pay-to-Script-Hash）交易。

该类交易目前不是很常见，大部分人可能没有听说过，但是非常有意义。未来应该会在某些场合频繁使用。该类交易的接受地址不是通常意义的地址，而是一个合成地址，以`3`开头 (Segwit交易其实也可以看成是Script Hash TX)。比如三对公私钥，可以生成一个合成地址。在生成过程时指定n of 3中的n，n范围是[1, 3]，若n=1，则仅需一个私钥签名即可花费该地址的币，若n=3，则需要三把私钥依次签名才可以。 这种类型的交易适合比较复杂的保险、证券场景。

#### 多重签名脚本|Multisig

尽管P2SH 多重签名脚本一般用于多重签名的交易，但是这个基础性的脚本也可以用于这种场景：当一个UTXO被使用之前，需要多重签名验证。

多重签名公钥脚本可以一般称为 m-of-n，至少需要m 个匹配公钥，n提供的公钥总数。m 和n 都应当根据需要的数量进行从OP_1到OP_16运算。

多重签名的交易细节更多，待我们搞明白最标准的比特币交易后，再来探究它。

#### Pubkey Hash TX

也被称为P2PKH（Pay-to-Public-Key-Hash）交易。该类是最常见的交易类型，由N个输入、M个输出构成。交易地址都是以`1`开头。这种交易也是目前比特币网络中最典型的交易类型，也最简明，容易分析。下面我们就先拿它作为例子，开始探究一笔比特币交易的细节。



## 数据结构

### 输入输出


简单来看，一笔完整的P2PKH交易包含有两个部分:输入UTXO -> 输出UTXO，而每一个输入UTXO其实是上一笔交易的输出UTXO，这么说可能有点绕口，来张图解释一下：

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20181203/bg1.jpg)

首先最前面的字段是版本号，每一个交易具有一个四字节的交易版本号，它告知比特币节点和矿工应使用哪一套规则来验证它。这使得开发者在为未来的交易创建新规则时可以不验证之前的交易。

接着就是输入的M个UTXO和输出的N个UTXO，代表着我要把一堆UTXO转移(支付)给谁。

最后是一个字段是锁定时间(Locktime)。Locktime 允许签名者创建一个时间锁定交易。因为只会在将来生效，这给签名者一个的反悔的机会。

如果其中任何一个签名者反悔了，他可以创建一个没有locktime 的交易。因为新创建的交易可以花掉旧交易的那部分input，所以旧交易在lock time解锁后 找不到可以花掉的input，旧交易就失效了。

一笔交易中，构造的输出UTXO会完全花费掉输入的UTXO，注意：是完全花费掉。如果输出UTXO的总额小于输入UTXO的话，那么差值就会被系统作为矿工费奖励打包到Generation TX当中。所以所有的比特币钱包实现中，如果你有10BTC的UTXO集合，想要花掉9BTC，那么输出UTXO中，除了支付给收款方的UTXO，还一定要构造发送给自己的找零UTXO。曾经有人构造交易时忘记找零，发生了[支付 200 BTC 的矿工费](https://blockchain.info/tx/4ed20e0768124bc67dc684d57941be1482ccdaa45dadb64be12afba8c8554537)的惨案，所幸的是收录该笔交易的Block由著名挖矿团队“烤猫（Friedcat）”挖得，该团队非常厚道的[退回了多余费用](https://blockchain.info/tx/b18abce37b48a5f434f108ae7ce34f22aa2bfbd9eb9310314029e4b9e3c7cf95)。

早期Geek们比较作死，特别喜欢命令行构造发送交易，像是忘记构造找零而当了冤大头的人数不胜数，那么为什么是这么奇葩的设计呢？为什么一笔交易中，一定要花费所有的输入UTXO呢？

大家还记得我们的上一篇文章吧，一个分布式的账本，最容易的设计就是只支持`append`这个动作，诸如`update`、`delete`这种操作在区块链账本的设计中会引入额外的复杂性，尤其是后面我们讲述blockchain的组织的时候，你就会理解，这种设计的必要性。


### 细节

一笔完整的P2PKH 交易是这样的：

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20181203/bg2.jpg)


我们用之前文章中，利用`satoshi`生成的地址(`1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE`)做例子，来研究它花费的[一笔交易](https://www.blockchain.com/btc/tx/3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517)。


用[在线getrawtransaction工具](http://chainquery.com/bitcoin-api/getrawtransaction/3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517/1) 解码一下这笔交易，得到输出：


```
{
	"result": {
		"txid": "3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517",
		"hash": "3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517",
		"version": 1,
		"size": 233,
		"vsize": 233,
		"locktime": 0,
		"vin": [
			{
				"txid": "b0a0afb65ac08f453b26fa03a40215be653b6d173510d366321019ab8248ea3b",
				"vout": 0,
				"scriptSig": {
					"asm": "304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0[ALL] 04c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5",
					"hex": "47304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0014104c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5"
				},
				"sequence": 4294967295
			}
		],
		"vout": [
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
		],
		"hex": "01000000013bea4882ab19103266d31035176d3b65be1502a403fa263b458fc05ab6afa0b0000000008a47304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0014104c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5ffffffff01581b000000000000232103db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603ac00000000",
		"blockhash": "0000000000000000001b29c4b36a6f9ccbb0213b02c7eb659c0eaee1244586fb",
		"confirmations": 85331,
		"time": 1494823668,
		"blocktime": 1494823668
	},
	"error": null,
	"id": null
}

```

#### 字段说明

##### txid (hash)

Tx Hash (3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517)，俗称交易ID，由hex得出：Tx Hash = SHA256(SHA256(hex))。由于每个交易只能成为下一个的输入，有且仅有一次，那么不存在输入完全相同的交易。因为SHA256碰撞的概率极小，所以理论上存在相同的Tx Hash 的概率非常小。

即便如此，在系统里依然产生了相同的Tx Hash，是不知道哪位矿工挖出Block后，打包Block时忘记修改Generation Tx coinbase字段的值，币量相同且输出至相同的地址，那么就构造了两个完全一模一样的交易，分别位于两个Block的第一个位置。这个对系统不会产生什么问题，但只要花费其中一笔，另一个也被花费了。相同的Generation Tx相当于覆盖了另一个，白白损失了挖出的币。该交易ID为[e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468](https://blockchain.info/tx/e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468)，第一次出现在[#91722](https://blockchain.info/block/00000000000271a2dc26e7667f8419f2e15416dc6955e5a6c6cdf3f2574dd08e)，第二次出现在[#91880](https://blockchain.info/block/00000000000743f190a18c5577a3c2d2a1f610ae9601ac046a38084ccb7cd721)。


##### vin (输入UTXO)

vin是一个数组，里面即M个输入UTXO，每个UTXO都来自上一笔交易的一个UTXO输出，这笔交易的vin只有一个UTXO，它由以下几个字段组成

1. txid: 上一笔关联交易的hash值
2. vout index: 上一笔交易输出的N个UTXO里面的序号
3. scriptSig: 对这笔UTXO的签名，还记得我们之前的文章吗？只有对一个UTXO签名才能证明其所有权，才能花费它
4. sequence: 序列号。这个序列号来源比较复杂；还记得上面讲的locktime有所关联：

> Locktime 允许签名者创建一个时间锁定交易。因为只会在将来生效，这给签名者一个的反悔的机会。
> 如果其中任何一个签名者反悔了，他可以创建一个没有locktime 的交易。因为新创建的交易可以花掉旧交易的那部分input，所以旧交易在lock time解锁后 找不到可以花掉的input，旧交易就失效了。            

> Bitcoin Core 的早期版本提供了一个可以防止签名者使用上述方法取消locktime 交易的功能。 后来为了防止大量的延时交易攻击网络，这个功能被禁用了。但是该系统还留下了这样的设置，每个输入会分配一个四字节的序列号。序列号的目的旨在允许多个签名者同意更新交易。

> 如果sequence number设置为0，就按照locktime执行入块操作，如果出现一笔新的交易，sequence大于原来的sequence，这笔新交易就会取代原来的交易；所以一般为了即刻入块，交易的sequence number一般设置为四字节的的无符号最大值(0xffffffff),使得交易的locktime 仍然有效的情况下，打包交易进块。

> 即使今天，如果所有的input 的sequence number都是最大值，locktime锁就会失效。所以如果想使用locktime，至少一个input的sequence number要小于最大值。由于sequence number不用于其他目的，任何sequence number 为零的交易都会启动locktime 功能。后面我们会看到，sequence number会在闪电网络中发挥作用

vin的所有UTXO 余额相加，就是这笔交易的转账总额。

##### vout (输出UTXO)

1. value: 转账金额
2. n: 作为第N个UTXO输出
3. scriptPubKey: 这是设置的谜题，后来人想要花费这笔UTXO，必须提供scriptSig来解答这个谜题才可以

* vin 的总额 - vout的总额 == 打包费用 -> 奖励给打包矿工

#### 交易十六进制解析

spec规范在[这里](https://en.bitcoin.it/wiki/Protocol_documentation#tx)

这笔交易的vin及vout中各有一个UTXO，我们解析下它的十六进制原始数据:


```
01000000013bea4882ab19103266d31035176d3b65be1502a403fa263b458fc05ab6afa0b0000000008a47304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0014104c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5ffffffff01581b000000000000232103db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603ac00000000

```

##### version (4字节): 刚开始的4个字节是version，小端排序(Little Endian)，因此version为`0x00000001`

> ps:关于小端排序的设计，社区里面还有过小争论，见[这里](https://bitcointalk.org/index.php?topic=4278.0)

##### flag (2字节，可选): 如果是`0001`，代表是witness交易；如果不是，就代表没有这个flag字段；这是一笔普通的交易，因此没有flag字段

##### vin count (>=1字节): vin数目，此交易为`01`，采用的是[var_int](https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer)表示法，这样我们能方便的测算它的长度

##### vin (>=41字节): 所有的输入tx，是一个数组；这里只有一个tx，数据是:

```
3bea4882ab19103266d31035176d3b65be1502a403fa263b458fc05ab6afa0b0000000008a47304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0014104c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5ffffffff

```

简单说下vin中一笔tx内部结构:

1. previous_output (32字节): 上一笔交易的HASH值，即这个花费的输入交易ID: 


```
    3bea4882ab19103266d31035176d3b65be1502a403fa263b458fc05ab6afa0b0
    -> 转为大端排序  
    b0a0afb65ac08f453b26fa03a40215be653b6d173510d366321019ab8248ea3b

```

2. previous output index: 表示花费的是 previous_output 交易的第n个vout输出，这里是`00000000`
    
3. script length (var_int变长，代表script的长度): 这里是`0x8a`，表示script长度为138字节
    
4. scriptSig (整个解密脚本)： 这个结构我们之后会具体分析

```
47304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0014104c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5

```

5. sequence no (4个字节): `ffffffff`
    

##### vout count (>=1字节): vout数目，此处为`01`

##### vout (>=9字节): 所有的输出tx，是一个数组；这里只有一个tx，数据是:


```
581b0000000000002103db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603ac

```

简单说下vout中一笔tx内部结构:

1. value (8字节): 转账到这个地址上的金额， 这里是`581b000000000000`小端排序，十六进制为`00000000000000581b`，即转账7000 satoshis
2. scriptPubKey length (>=1, var_int类型): 输出脚本的长度，这里是`0x23`，代表35字节长度
3. scriptPubKey: 输出脚本，其实就是包含转账地址的脚本，这里是`2103db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603ac`
    
##### locktime: 最后4个字节是locktime，这笔交易设置为0；就是立即打包

## 总览

##### 最后一张表格说明问题：

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20181203/bg3.jpg)

##### 再来一张交易的总体示意图:

![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20181203/bg4.jpg)


1. TX0， input0即 vin0，里面有一笔100K satoshis比特币(1btc=10^8 satoshi)
2. TX1、TX2 花费了 TX0-vin0，分成了TX1-vin0(40k satoshi)，以及TX2-vin0(50k satoshi)，还有10k satoshi作为交易费给矿工
3. TX3花费了TX1-vin0 (30k satoshi)，付出了10k satoshi 交易费
4. TX4、TX5 花费了 TX2-vin0，分成了TX4-vin0(20k satoshi)，以及TX5-vin0(20k satohsi)，付出了10k satoshi交易费
5. TX6花费了TX4-vin0 + TX-5-vin0，共20K(satoshi)，其余的20k satoshi为交易费
6. 最后又花费了TX3-vin0中的20k satoshi, 10k satoshi作为交易费
7. 最后又花费了TX6-vin0，TX6-vin1中的10k satoshi, 10k satoshi作为交易费


## 小结

好了，到这里；我们对于一笔最简单的比特币的交易结构已经详细分析了一遍；但是在全网中，交易是怎样验证的呢？一笔资金从A转移到B，全节点怎么验证这次转移的合法性呢？


这就用到了比特币的脚本语言系统，具体到上面的示例交易，就是scriptSig与scriptPubKey；

那么scriptSig与scriptPubKey是怎么工作的呢？我们下次文章再会。

## 参考资料:

https://en.bitcoin.it/wiki/Protocol_documentation

http://learnmeabitcoin.com/

http://www.righto.com/2014/02/bitcoins-hard-way-using-raw-bitcoin.html

https://0dayzh.gitbooks.io/bitcoin_developer_guide/content/standard_transactions.html

https://www.8btc.com/article/24637
