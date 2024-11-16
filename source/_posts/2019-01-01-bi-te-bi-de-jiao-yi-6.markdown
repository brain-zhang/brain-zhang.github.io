---
layout: post
title: "比特币的交易-6"
date: 2019-01-01 20:10:54 +0800
comments: true
categories: blockchain
---

好啦，这篇文章中，我们要来探讨大名鼎鼎的Segwit(Segregated Witness)。

这个词一说起来就头疼啊，他牵扯到旷日持久的扩容大战，无穷尽的争论以及分裂。我们的立场就是不去站队任何组织，单纯从技术的角度去理解这个东西。

<!-- more -->

首先澄清一个误解，其实Segwit跟扩容没关系，它最初提出来，只是为了解决交易延展性的问题，顺便有一点扩容效果，但这个扩容效果只是附带的；

另外，其实Segwit的技术原理非常简单，但是要考虑兼容性的问题，导致从设计到实施都有点复杂。


## 缘起

嗯哼，又要涉及到大量的数学知识；先声明下，我至今还没有从数学原理上完全理解椭圆曲线算法，所以下面讲的都是码农派的API理解--搞明白接口，但里面的细节还需要更多时间去探究。

上一篇文章我们提到，当交易被签名时，签名并没有覆盖交易中所有的数据 (因为签名是不可能对自身签名的)，而交易中所有的数据又会被用来生成交易的哈希值来作为该交易的唯一标示。

如果签名向常见的HASH算法一样，碰撞机率极小的话也没有问题；但是椭圆曲线算法存在一个看起来比较弱的特性：

> ECDSA算法生成两个大整数r和s并组合起来作为签名, 可以用来验证交易。而r和BN-s 也同样可以作为签名来验证交易(BN＝0xFFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141). 这样，攻击者拿到一个交易，将其中inputSig 的r, s 提取出来， 使用 r, BN-s 生成新的inputSig, 然后组成新的交易，拥有同样的input和output，但是不同的TXID. 攻击者能在不掌握私钥的情况下几乎无成本地成功地生成了合法的交易。

让我们再用码农能理解的语言描述一遍:

1. 前面的交易中，scriptSig脚本可以提取出sig签名
2. sig是由两个值组成的，Sig=(R,S)
3. sig是嵌入在scriptSig中，用一种名为` DER-encoded ASN.1 octet representation`的编码方式编码的。OpenSSL并没有强制要求每个签名编码结果只能有一个值。
4. 对于每一个 ECDSA `signature(R,S)`，还存在相同消息的另外一个有效签名: `signature(R,-S(mod N))` 
5. 一个恶意攻击者得到Sig之后，可以手工构造另外一个`signature(R,-S(mod N))`嵌入到scriptSig中，这和之前的scriptSig不一样，所以TX ID也会发生变化
6. 这笔新的交易输入输出跟原来的交易完全一样，也是合法的，但是TX ID不同了。

#### 危害

1. Alice通过在线钱包给Bob发送了一笔交易，并把TXID发送给Bob说，看我给你发了多少比特币
2. 黑客截获了这笔交易，然后构造了一个新的签名广播出去，替换了原来的交易
3. Bob 通过Alice发来的TXID搜索了以下，并没有发现这笔交易
4. Bob说，Alice是个骗子

#### 对于交易所的威胁

1. 黑客向交易所发起来一笔资金提现
2. 交易所自动处理，广播了交易，并发送给黑客TX ID
3. 黑客截获了这笔交易，然后构造了一个新的签名广播出去，替换了原来的交易
4. 黑客对交易所说，我没有收到资金，那笔交易不存在
5. 交易所验证了下，因为原来得交易已经被黑客替换掉了，所以原始交易果然不存在了
6. 交易所只能又构造了一笔交易再次广播
7. 黑客最后得到了两笔资金
8. 这种情况下的解决方法是，遇到交易无法确认就停止，报错误并等待手动处理，或者，我们可以自己生成一个延展性交易，然后获取新的TXID,查找是否发送成功。能生成的TXID数量有多少呢？一共有exp(2, input数量)个，因为每个input都有改签名或者不改两种可能， 通常不是一个大数目。
9. 但是这不能阻挡脚本小子的恶意攻击，他们通常会`损人不利己`的构造大笔延展性交易来攻击网络


## 讨论

社区为了解决这个问题进行了大量的讨论：以下是一些材料和社区进行的努力：

#### BIP0062

https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki


#### BIP66

在 363742 区块高度处，BIP66 软分叉强制区块链中所有新交易遵循 DER-encoded ASN.1 标准。仍然需要进一步的努力来关闭 DER 签名其它可能的延展性问题。
签名仍然是可以被拥有相应私钥的人改变的。


## 解决

2015年12月，Bitcoin Core开发团队的[Pieter Wuille](https://github.com/sipa)提出了一个解决方案，称之为隔离见证 (Segregated Witness）。隔离见证由以下BIPs定义：

1. BIP-141:隔离见证的主要定义
2. BIP-143:版本0见证程序的交易签名验证
3. BIP-144对等服务——新的网络消息和序列化格式
4. BIP-145隔离见证（对于矿工）的 getblocktemplate 升级

最主要的描述在BIP141中:

https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki


## 原理

其实说白了原理非常简单，就是把vin的scriptSig挪到交易的末尾去。

每一个比特币交易，其实可以分为两部份。第一部份是说明结余的进出，第二部份是用来证明这个交易的合法性 (主要是签署)。第一部份可称为「交易状态」，第二部份就是所谓的「见证」(witness)。如果你只关心每个账户的结馀，其实交易状态资料就已经足够。只有部份人(主要是矿工)才有必要取得交易见证。

那么我们再来复习下一笔P2PKH交易的结构:


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

在整笔交易里面，输入输出信息以及金额大小属于第一部分，scriptSig属于第二部分。

只有矿工以及全节点需要进行scriptSig的验证；如果是普通的SPV轻钱包只需要验证所在区块的合法行就可以了。所以可以把scriptSig 部分挪到交易的尾部。这样带签名的原始数据就固定了，也不会有更改TX ID的机会。这部分数据称之为witness:

每个witness都由一个var_int打头，代表接下来的数据长度。如果某个输入没有见证，那么其witness就是一个0x00。

让我们代入各种例子，来看看Segwit是如何工作的？


#### P2WPKH (Pay-to-Witness-Public-Key-Hash)

首先回顾下P2PKH的锁定脚本(scriptPubKey)与解锁脚本(scriptSig)内容

* P2PKH

```
  scriptSig:    <signature> <pubkey>
  scriptPubKey: OP_DUP OP_HASH160 <20-byte hash of Pubkey> OP_EQUALVERIFY OP_CHECKSIG

```

再来看一下P2WPKH的脚本内容

* P2WPKH  

```
  scriptSig:    (empty)
  scriptPubKey: 0 <20-byte hash of Pubkey>
  witness:      <signature> <pubkey>

```

P2WPKH的锁定脚本较P2PKH要精简不少，第一位的数字0是版本号，有了版本号，未来脚本升级就能更容易的向前兼容。

P2WPKH的解锁脚本为空，而真正的解锁脚本内容被移到了原交易之外的witness部分。

#### P2WSH(Pay-to-Witness-Script-Hash)

* P2SH


```
  scriptSig:    0 <SigA> <SigB> <2 PubkeyA PubkeyB PubkeyC PubkeyD PubkeyE 5 CHECKMULTISIG>
  scriptPubKey: HASH160 <20-byte hash of redeem script> EQUAL

```

* P2WSH  

```
  scriptSig:    (empty)
  scriptPubKey: 0 <32-byte hash of redeem script>
  witness:      0 <SigA> <SigB> <2 PubkeyA PubkeyB PubkeyC PubkeyD PubkeyE 5 CHECKMULTISIG>

```

P2WSH锁定脚本与P2WPKH类似，第一位是版本号，第二位是赎回脚本(Redeem script)的Hash值。

值得注意的是P2WSH锁定脚本中的Hash值是256位(32字节)的，是使用SHA256(pubkey)计算得到；而P2WPKH中的Hash值是160位(20字节)的，是使用RIPEMD160(SHA256(pubkey))计算得到的。

这样做的目的是让钱包可以根据Hash值的长度区分交易使用的是P2WPKH还是P2WSH。

在P2SH交易中常常会有多重签名验证，所以验证信息会占用更多空间，将这些信息移到原交易之外能更大程度的降低交易大小。

#### 锁定脚本版本号

仔细观察之后，我们发现scriptSig以及scriptPubKey都以一个`0`开头；这代表着一个版本号。开发团队对于这个字段还有更远大的愿景，锁定脚本(Locking script)加上版本号，从而使脚本语言的升级更容易向前兼容，这种不造成太大影响的脚本语言修改方式将加快比特币的创新。

这个字段的精巧之处就在于，老节点看到这种交易也是合法的，虽然不能正确parse这种交易，但是当作为交易被打包到一个新区块，然后被支持segwit的矿工挖出来这个块，其它不支持segwit的老节点也是承认这个块的！

为什么呢？复习一下我们之前的文章，在一笔交易结构里面，这种交易是合法的 (是的，真相其实更复杂，但是我懒得详细介绍了，也许之后更闲的时候会仔细说说吧)！

虽然不能正确解析，但格式合法。有的人觉得这种技术忒精巧了，甚至精巧到了一种可怕的程度，是一种杂耍式的开发。很多人对于这种`啊哈`式的适配吓坏了。

现在Segwit已成事实，是非曲直只能留给你自己去判断了。

#### 交易标识符

从上面看，其实实施Segwit之后，数据结构反而变得更清晰简单了。如果中本聪一开始就采用这样的结构，我相信也没有多少人会质疑。

但是已有的老的交易格式及相关系统已经运行了这么长时间，我们希望能尽可能的兼容以前的系统。最麻烦的适配就是原来传统交易的ID只有一个txid。现在见证数据挪到后面了，HASH的时候就不包括这一块数据了，怎么办？

传统交易的txid是以下序列 double sha256的结果:


```
[nVersion][txins][txouts][nLockTime]

```

最后开发者们又引入了另外一个id，称之为wtxid；它是对整个交易double sha256的结果:


```
[nVersion][marker][flag][txins][txouts][witness][nLockTime]

```

我们知道，每笔交易的txid是临时计算的，并不入块。但是整个Block是以所有交易的txid以Merkle Tree的形式组织的(这部分知识我们还没讲，需要到后面将bitcoin blockchain的时候提到)；现在多了一个wtxid，该怎么办呢？

解决办法又让人有点无语，就是将wtxid按照同样的组织方法算出Merkle Tree根节点，放到Block块中。

但是原有的Block格式都固定下来了，这个根节点放哪里呢？

还有coinbase的100个字节是可以利用的嘛，就是你了。

这~~~~~，在有洁癖的人看来，完全又是一种码农修修补补式的FIX；相信众多技术人员这个时候已经开始内心无数吐槽了；但是真实世界就是这样无奈啊，又想要兼容性，又想要代码干净，又想要性能~~~~

你是太阳吗！？地球都绕着你转吗？！

拿着吧，这就不少了！！


最后附上这段龌龊的代码：


```
std::vector<unsigned char> GenerateCoinbaseCommitment(CBlock& block, const CBlockIndex* pindexPrev, 
                                                      const Consensus::Params& consensusParams)
{
    std::vector<unsigned char> commitment;
    int commitpos = GetWitnessCommitmentIndex(block);  //从币基交易的输出中寻找承诺项，没找到就返回-1
    std::vector<unsigned char> ret(32, 0x00);
    if (consensusParams.vDeployments[Consensus::DEPLOYMENT_SEGWIT].nTimeout != 0) {
        if (commitpos == -1) {  //没有找到，就开始创建承诺，先生成见证版Merkle树根
            uint256 witnessroot = BlockWitnessMerkleRoot(block, nullptr);
            CHash256().Write(witnessroot.begin(), 32).Write(ret.data(), 32).Finalize(witnessroot.begin());
            CTxOut out;  //构建一个币基交易的输出
            out.nValue = 0;  //金额是0
            out.scriptPubKey.resize(38);  //公钥脚本长度38，前6个字节固定为0x6a24aa21a9ed
            out.scriptPubKey[0] = OP_RETURN;  //0x6a
            out.scriptPubKey[1] = 0x24;  //36，即后面的总长度
            out.scriptPubKey[2] = 0xaa;  //0xaa21a9ed，固定不变的承诺头
            out.scriptPubKey[3] = 0x21;
            out.scriptPubKey[4] = 0xa9;
            out.scriptPubKey[5] = 0xed;
            memcpy(&out.scriptPubKey[6], witnessroot.begin(), 32);  //插入见证版Merkle树根
            commitment = std::vector<unsigned char>(out.scriptPubKey.begin(), out.scriptPubKey.end());
            CMutableTransaction tx(*block.vtx[0]);
            tx.vout.push_back(out);  //币基交易中添加这个输出
            block.vtx[0] = MakeTransactionRef(std::move(tx));  //写回区块
        }
    }
    UpdateUncommittedBlockStructures(block, pindexPrev, consensusParams);  //更新区块其他结构
    return commitment;
}


```

#### 隔离见证新的签名算法

原来的签名验证需要大量的HASH操作；我们知道比特币是一个分布式系统，同时运行着上万个节点，如果一个操作每个节点都执行一遍，浪费的操作加起来很惊人的。

而隔离验证是个软分叉，为啥不能顺便再搞一点优化呢？毕竟软分叉的机会不多啊。于是开发者们顺便修改了四个签名验证函数（CHECKSIG，CHECKSIGVERIFY，CHECKMULTISIG和CHECKMULTISIGVERIFY）的语义，改变了交易承诺散列的计算方式。

下面的说明引用自 Master Bitcoin:

> 比特币交易中的签名应用于交易哈希，交易数据计算，锁定数据的特定部分，表明签名者对这些值的承诺。例如，在简单的SIGHASH_ALL类型签名中，承诺哈希包括所有的输入和输出。

> 不幸的是，计算承诺哈希的方式引入了验证签名的节点可能被迫执行大量哈希计算的可能性。具体而言，散列运算相对于交易中的签名操作的数量增加O（n^2）。因此，攻击者可以通过大量的签名操作创建一个交易，导致整个比特币网络不得不执行数百或数千个哈希操作来验证交易。

> Segwit代表了通过改变承诺散列计算方式来解决这个问题的机会。对于segwit版本0见证程序，使用BIP-143中规定的改进的承诺哈希算法进行签名验证。

> 新算法实现了两个重要目标。首先，散列操作的数量比签名操作的数量增加了一个更加渐进的O（n），减少了用过于复杂的交易创建拒绝服务攻击的机会。其次，承诺散列现在还包括作为承诺的一部分的每个输入的值（金额）。这意味着签名者可以提交特定的输入值，而不需要“获取”并检查输入引用的前一个交易。在离线设备（如硬件钱包）的情况下，这极大地简化了主机与硬件钱包之间的通信，消除了对以前的交易流进行验证的需要。硬件钱包可以接受不可信主机“输入”的输入值。由于签名是无效的，如果输入值不正确，硬件钱包在签名输入之前不需要验证该值。

总之就是一句话，提升了验证签名的性能！！


## 实施

隔离见证（segwit）是一次比特币共识规则和网络协议的升级，其提议和实施将基于BIP-9，是一个软分叉。

2017年8月24日，区块高度481,824，隔离见证正式激活。

2015年提出，2017年激活；想想就知道这中间经历了多少曲折！！

隔离见证最终是全网95%的算力投票赞成才激活的，即使如此，网络中还是有一些不支持隔离见证的老节点在运行，同时，周边的钱包等软件也有不少还不支持隔离见证交易；此时的情况就比较复杂:

#### 付款人的客户端支持隔离见证，而收款人不支持

如果收款人不支持隔离见证，那最终发布的地址将会是普通地址（P2PKH或P2SH），那所有交易按照原有的规则进行即可。

#### 付款人的客户端不支持隔离见证，而收款人支持

聪明的社区开发者想出了一个过渡方案，即将P2WPKH或P2WSH植入P2SH。

是的！！作为有洁癖的开发者，你又会要吐槽了，这是什么操作！？

P2WPKH植入P2SH后，交易信息如下：


```
  scriptSig:    0 <20-byte hash of Pubkey>
  scriptPubKey: HASH160 <20-byte hash of script> EQUAL
  witness:      <signature> <pubkey>

```

此处的脚本Hash值为RIPEMD160(SHA256(0 <20-byte hash of Pubkey>))的结果，将该脚本Hash转换为P2SH地址，就是一个兼容segwit的地址，不支持隔离见证的客户端可以正常支付比特币给这种P2SH地址。
而对于支持隔离见证的客户端，仍可以将验证信息放在witness结构中，当然这种过渡方案的交易会较完全形态的方案稍大一些，但比无隔离见证的情况要小。

这样就引入了另外一个混乱之处，我们前面的文章提到过，以`3`开头的地址是P2SH交易专用的，而P2SH交易一般包含的脚本逻辑比较复杂，现在又要判断一种情况，这笔交易是不是一笔隔离见证交易呢？

还有普通小白也很疑惑，比特币网络中开始出现大量以`3`开头地址的交易，之前这种交易很少，小白们甚至都没有见过这种地址。

为了解决这个问题，开发者们很快又提出了bech32地址格式(去参考我们之前的文章)，小白们很快就被搞得晕头转向。而此时社区正处于分裂状态，Bitcoin Cash作为硬分叉出来的江湖搅局者，虽然加入了重放保护，但是地址和Bitcoin的规则是一样的，但是Bitcoin Cash是不支持Segwit的！

很快，就有大量的小白在Bitcoin Cash里面发送交易给Segwit地址，这种混乱场景不忍卒见。

然后，Bitcoin Cash也搞出了自己的另外一套地址规则；好吧，你应该去找找我们早期的关于比特币钱包的文章，好好温习一下了。


#### 一些吐槽

令人惊奇的是，这段混乱时期，在全网交易纷纷堵死，隔离见证升级、Bitcoin Cash分叉的混乱局面中，比特币的价格不合常理的大涨、暴涨，涨到大家怀疑人生。颇有一点狂风暴雨雷霆霹雳之下，大家在泰坦尼克号中末日狂欢的意味。

Bitcoin这个东西，实在不能以常理来琢磨啊。

## 优点


说了这么多，当然Segwit的升级还是又非常多的好处的~~~

#### 可以用软分叉增加最大区块容量:

因为旧有节点根本看不到这些被隔离的见证，即使真实的区块已超过1MB，它们仍会以为没有超过限制而会接受区块。

比特币的区块大小限制为1000000bytes，由于witness数据不包含在这个限制中，为了防止witness数据被滥用，仍然对总的区块大小做了限制。引入了一个新概念叫块重量(Block weight):


```
Block weight = Base size * 3 + Total size
Base size是不包含witness数据的块大小
Total size是包含了witness数据的总大小

```

隔离见证限制Block weight <= 4000000

这就是隔离见证扩容说的来由，这样实际上确实有一定的扩容效果，如果全网交易都迁移到隔离见证上来，大概扩容1.7倍吧。

但是!!! 注意，实际的区块链大小其实比原来更大，这一点一定要搞清楚。

#### 解决了交易延展性问题

从此以後，只有发出交易的人才可以改变交易ID，没有任何第三方可以做到。如果是多重签名交易，就只有多名签署人同意才能改变交易ID。这可以保证一连串的未确认交易的有效性，是双向支付通道或闪电网络所必须的功能。有了双向支付通道或闪电网络，二人或多人之间就可以实际上进行无限次交易，而无需把大量零碎交易放在区块链，大为减低区块空间压力。

#### 轻量钱包可以变得更轻量，因为它们无需再接收见证数据

#### 可以大幅改善签署结构

在区块链上，曾经有一个超过5000个输入的交易，因为签署设计缺憾，需要半分钟才能完成检查。在建议中的SW软分叉会把这个问题解决掉。

而在该次软分叉完成後，核心开发者们已有计划进一步完善整个系统的可用性和安全性:

1. 全节点可以为轻量钱包提供很简洁的证明，以检查交易是否合法。以後的节点就不再局限於完全验证和完全不验证，而是可以按个人的资源作部份验证，也就是说一台手机也可以参与保障系统安全。这可以大为降低系统对全节点的依赖，即使以後区块容量提升了，我们仍能保持安全。

2. 将会推出全新的交易脚本语言，例如可以把数以千计的不同脚本通过MAST技术压缩至只有32字节;亦可以把不同签署合并检查，令检查交易的速度再以倍数上升。


#### 为闪电网络的实施铺平了道路

闪电网络应该是继中本聪创造比特币之后最重量级的创新，支持者和反对者为其吵了一个天翻地覆，这个值得我们后面写文章大书特书，还是那句话，后文再见吧。


## 副作用


#### 复杂性

是的，如果你看到这里；就会发现我到了大量的`吐槽`字眼；为了达成共识，隔离见证采用了软分叉升级，为了兼容老系统，不可避免的修修补补；另外虽然说起来是单独的一项技术，同时解决的问题可不少，在洁癖者眼里，这是屌丝码农的瞎折腾，就增加了出Bug的可能性；如果是个硬分叉，所有技术问题能干净利落解决，就没有这么多争吵了。

总之一句话，隔离验证留下的技术债不少，升级之后落子无悔，如果之后发现问题，可没机会回退了。

这次升级也是一次经典的技术、政治、利益交杂的各方博弈，如果将来比特币大成，这段历史值得仔细研究。

#### Block Size

前面已经在优点里面说过了。隔离见证有扩容效果的。但这个效果只是一个副作用，只是当时提出隔离见证的时候社区正就扩容问题吵得不可开交，莫名其妙的这个技术就卷入扩容斗争里面了。

再说一遍：关于隔离见证，网上一个很大的误解就是：认为witness被隔离走了，witness数据不在Block里，所以一个Block能装更多的Transaction。

其实不是，witness数据仍然在Block里面。并且对于1个Transaction来说，如果把witness数据也算上的话，其raw byte size其实是变大了，而不是变小了。
既然Transaction还变大了，那为什么1个Block可以装更多的Transaction呢？

因为隔离见证是软分叉，不是硬分叉。下面就分别来分析一下，为什么对于老版本节点、新版本节点，1个Block都可以装更多的Transaction呢？

对于老版本节点： 
Block Limit Size = 1M，但由于你把witness数据移到了所有Transaction的外面，放在了整个Block的尾部。老版本在计算一个Block大小的时候，只计算了 
Block Header + 所有Transaction的数据（witness数据，老版本看不见，相当于老版本被欺骗了。）

所以呢，其实整个Block的物理大小(raw block size)已经超过了1M，但老版本的节点不认识尾部的witness数据，所以认为总大小还是 < 1M。

对于新版本节点： 
Block的size的计算方式做了调整，引入了Block weight的概念。 


```
block weight = base_size * 4 + witness_size 
block weight <= 4M

```

其中，base_size就是block的前2部分数据（header + 没有witness的所有交易数据）

通过上面的分析，我们会发现，数据还是那么多数据，没有减少，只是重新排布了一下，却变相的把区块链扩容了。


#### 安全性

有人提出来说，中本聪之前把交易信息和见证数据放在一块是有意的；因为一笔交易带有所有者的签名是天经地义的语义；隔离见证把witness独立出来，降低了比特币系统的安全性。另外~~~~

老实说，这个论据仔细读读还是蛮有道理的，但是实在说的太深刻太哲理了，码农对这种东西天生无感，我就不啰嗦了，大家感兴趣可以自己去搜索这方面资料。


##  小结

以上就是对隔离见证这个东东最简单的描述，我尽力做到简洁中立；但是实际上我觉得整个过程写一本书也不为过；

那么，隔离见证实施之后；就是闪电网络的崛起了，我们下篇文章再见。


## 参考

#### 四份有关隔离见证的比特币改善方案: 

* 隔离见证软分叉

https://github.com/CodeShark/bips/blob/segwit/bip-codeshark-jl2012-segwit.mediawiki 

* 隔离见证通信层

https://github.com/CodeShark/bips/blob/segwit_peer_services/bip-codeshark-segwit-peer-services.mediawiki 

* 隔离见证交易地址

https://github.com/jl2012/bips/blob/segwit-address/bip-segwitaddress.mediawiki 

* 隔离见证签署检查

https://github.com/jl2012/bips/blob/segwit-checksig/bip-segwit-checksig.mediawiki


#### 系统扩展常见问题解答:

https://bitcoin.org/zh_CN/bitcoin-core/capacity-increases-faq

#### 需要30秒检查的交易: 

https://blockchain.info/tx/bb41a757f405890fb0f5856228e23b715702d714d59bf2b1feb70d8b2b4e3e08

#### 其它资料

https://github.com/tianmingyun/MasterBitcoin2CN/blob/master/appdx-segwit.md

