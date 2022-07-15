---
layout: post
title: "十行代码挑战世界金融体系"
date: 2020-04-23 15:47:39 +0800
comments: true
categories: blockchain
---
这个有点标题党了，但实话说许多"高科技"项目也是这种浮夸的宣传手段，且听我慢慢道来；

最近央行将推出数字货币（DCEP）的消息沸沸扬扬，在没有实际用过之前，我无意对其做过多揣测；

不过这个消息激起了我另一方面的兴趣，就是写一写那些在以太坊上面发行的各种山寨Token；

众所周知，自从Ethereum的[ERC20](https://github.com/ethereum/EIPs/issues/20)、[ERC223](https://github.com/ethereum/EIPs/issues/223)、[ERC721](https://github.com/ethereum/EIPs/issues/721)、[ERC777](https://github.com/ethereum/EIPs/issues/777)等Token合约标准诞生以来，在Ethereum上面发行一种货币的成本低的令人发指，我测算，按照现在的ETH汇率，大概10块人民币就能让你发行一个具有发行、转账、增发、销毁等基本功能的电子货币，如果导入OpenZeppelin程序库，在部署合约的时候多出100块钱左右，就可以拥有一个具有融资上限、拍卖、行权计划和其他更复杂的功能的货币。

先知Andreas M. Antonopoulos 曾经在2014年加拿大关于比特币的听证会上表示，未来的货币发行市场可能会超出所有人的想象，一个十几岁的屁大小子，用10行代码足以创造最灵活最有信用的货币；借助区块链的技术，一个幼儿园的童星创造的货币，可能比历史上最有权力的君王创造的货币用户更多；

虽然比特币发明以来，把它的代码Folk一份，修改两个参数就出来"颠覆世界"的山寨币已经数不胜数，但真正把"造币"这件事情变成无门槛，像吃棒棒糖一样容易的，还是得说以太坊的ERC20的横空出世；

那么，就先让我们体验一下，如何10行代码创造我们自己的棒棒糖币吧~~~

<!-- more -->

### 前置技能

虽然夸张的宣传是只需要十行代码，但是我们得懂一些前置技能:

1. 会翻墙
2. 了解[Ethereum](https://ethereum.org/)的基本原理，最好能把白皮书读明白
3. 学会[solidity语言](https://github.com/ethereum/solidity/)
4. 搞明白[Truffle开发环境的使用](trufflesuite.com/)
5. 会用Nodejs
6. 会用Npm安装包，因为相关代码迭代速度很快，有时候需要你自己解决一些依赖问题
7. 会一些基本的Linux命令

好啦，相信老码农对于以上小门槛根本不屑一顾；

我们假设你满足了上面的前置条件，在一台能翻墙的Linux机器上部署了Nodejs, Geth, Truffle，让我们开干吧；

### 初版

1. 首先我们要完成Truffle的搭建，与我们本地运行的Geth联动，保证你的地址里面有一点ETH能支付Gas费用，这部分操作可以参考官方文档

2. 然后我们用Truffle命令建立一个简单的模板项目

```
$ mkdir CakeCoin
$ cd CakeCoin
$ truffle init
```

3. 开始编辑我们的棒棒糖Token合约

```
$ vim contracts/CakeCoin.sol

pragma solidity ^0.5.0;
contract CakeCoin {
    mapping (address => uint256) public balanceOf;
    constructor(uint256 initialSupply) public {
        balanceOf[msg.sender] = initialSupply;
    }
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }
}

```
4. 编写一个部署脚本

```
$ vim migrations/2_deploy_contact.js

var CakeCoin = artifacts.require("CakeCoin");
module.exports = function(deployer) {
  deployer.deploy(CakeCoin);
};

```
5. 编译部署上链

```
$ truffle migrate
```

大功告成，在付出大概0.001ETH的Gas费用之后，你的私人货币就发行成功了，此时你有两项权力：

* 可以在部署的时候指定货币的总体供应量
* 可以执行央行的角色，把货币分发给其他人；至于分发的方式，就看你的心情了
    - 可以像以太坊众筹一样，为某个时间点的所有比特币持有者做个快照，然后按照比特币的持有量给所有持有人发币
    - 可以搞宣传诈骗，先创建一个美轮美奂的高大上的网站，然后引那些不明真相的群众花钱来买你成本只有0.001ETH的棒棒糖币
    - 纯粹为了玩，发行1000万亿货币随机分发给所有以太坊玩家；这也是大多数山寨Token的初始发行办法--先把场子热起来；


这个合虽然简单，但是已经完成了货币的基本功能：贮存和转移，而且是一个全球通用的，不需要任何组织背书，完全依赖于以太坊的数学体系运转的电子货币；

不要小看这10行代码哦，在所谓的“区块链技术”纷纷攘攘的日子里，很多所谓的金融创新就是靠着这样的代码，大肆圈钱；甚至有个国家，咱就不指明了，发行个啥石油币，本质上一样的套路；

### 第二版

虽然这个CakeCoin已经具备了最简单的发行和转账的功能，但是查询总发行量，账户持有量等等操作只能通过与合约交互来实现，对于非码农人士太困难了，我们需要增加必要的接口:

```
pragma solidity ^0.5.0;

contract CakeCoin {
/* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    uint256 public totalSupply;

    event TransferEvent(address indexed _from, address indexed _to, uint256 _value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(uint256 initialSupply) public {
        balanceOf[msg.sender] = initialSupply;
        totalSupply = initialSupply;
        // Give the creator all initial tokens
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
        // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Check for overflows
        balanceOf[msg.sender] -= _value;
        // Subtract from the sender
        balanceOf[_to] += _value;
        // Add the same to the recipient
        emit TransferEvent(msg.sender, _to, _value);
    }

        function getBalance(address addr) public view returns(uint) {
                return balanceOf[addr];
        }
}

```

然后提供一个web UI操作界面，具体代码可以参考：

https://github.com/brain-zhang/CakeCoin/tree/branches/1.2/src

### 第三版(ERC20)

上面的货币虽然简单好用，但是有一些缺陷：

* 初始发行量定了就不能改了，以后不能再增发货币
* 发行出去的货币无法注销
* 初始发行者的权利不能转让
* 无法开展融资等活动
* .....

为了解决这些问题，我们想要一个更高级一点的糖果货币；毕竟，金融就是一件把事情越做越复杂的活儿，这样才好浑水摸鱼嘛^_^；

这么搞下来10行代码肯定不止了，但是程序员最大的特长就是造轮子，早就有人把这些东西封装成现成的库合约了,比如这个项目：

https://github.com/OpenZeppelin/openzeppelin-contracts

我们引入一下，代码量反而更少了；

```
pragma solidity ^0.4.0;

import 'openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

contract CakeCoin is StandardToken {
    string public constant name = 'CakeCoin';
    string public constant symbol = 'CAKECOIN';
    uint8 public constant decimals = 2;
    uint constant _initial_supply = 10000;

    function CakeCoin() public {
        totalSupply_ = _initial_supply;
        balances[msg.sender] = _initial_supply;
        emit Transfer(address(0), msg.sender, _initial_supply);
    }
}

```

以上的合约相比我们第二版，可以一眼看出有几个变化:

1. 有了个正式的名字 `CakeCoin`, 这是ERC20的规范
2. 有了个正式的货币符号 `CAKECOIN`, 这是ERC20的规范
3. 有了精度限制, 这是ERC20的规范
4. 有了初始发行量, 这是ERC20的规范
5. 有了以上这些明文约定的东西，就很容易被第三方的交易所解析，可以直接上架交易

`openzeppelin-contracts` 项目发展非常快，为了便于演示，我们先采用其早期版本作为基础库；其truffle-config.js配置如下：

https://github.com/brain-zhang/CakeCoin/blob/branches/1.3/truffle-config.js

执行下面命令重新部署:

```
truffle migrate --reset
```


如此一来我们就有了一个完整的符合[ERC20](https://docs.openzeppelin.com/contracts/3.x/erc20)规范的代币；让我们先在命令行里面体验一下其能力：

```
$ truffle console

truffle(development)> CakeCoin.address

'0xb634675Ea3B3aDBb2B72A975cD7Ed04Be79c4873'

```

得到了合约的部署地址，然后我们执行下列命令看一下货币发行总量:

```
truffle(development)> let supply = await CakeCoin.deployed().then(instance => instance.totalSupply())
truffle(development)> supply.toString()

'10000'
```

接着，我们用本地的测试区块链上创建的账户进行一笔转账，并验证其余额:

```
truffle(development)> let accounts;
truffle(development)> web3.eth.getAccounts((err,res) => { accounts = res });
truffle(development)> CakeCoin.deployed().then(instance => { instance.balanceOf(accounts[0]).then((balance) => console.log(balance.toString())) })
truffle(development)> 10000

truffle(development)> CakeCoin.deployed().then(instance => { instance.transfer(accounts[1], 100) })

truffle(development)> CakeCoin.deployed().then(instance => { instance.balanceOf(accounts[0]).then((balance) => console.log(balance.toString())) })
truffle(development)> 9900

truffle(development)> CakeCoin.deployed().then(instance => { instance.balanceOf(accounts[1]).then((balance) => console.log(balance.toString())) })
truffle(development)> 100

```

OK，验证完毕，这样我们创造了一个符合ERC20规范，可以直接上架交易所，具备基本的发行、转账功能的代币；但是我们得到的还不止于此~~~

ERC20最大的功能创新是使用了approve和transferFrom的两步式交易。这个流程允许代币的持有人授权其他地址操纵他们的代币。这通常用于授权给某一个合约地址，进行代币的分发，但也可以用于交易所的场景。

例如，某个公司正在销售ICO的代币，他们使用授权某个众筹合约的地址进行一定数量的代币分发。这个众筹合约就可以使用transferFrom把代币从持有人的余额中转账给ICO代币的买方;

下面我们就演示如何创建一个众筹合约来配合我们的CakeCoin实现一个自动化的代币分发

#### 首先我们需要建立一个接收CakeCoin的合约Demo

```
pragma solidity ^0.4;

import 'openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

// A faucet for ERC20 token CakeCoin
contract CakeCoinFaucet {

        StandardToken public CakeCoin;
        address public CakeCoinOwner;

        // CakeCoinFaucet constructor, provide the address of CakeCoin contract and
        // the owner address we will be approved to transferFrom
        constructor(address _CakeCoin, address _CakeCoinOwner) public {

                // Initialize the CakeCoin from the address provided
                CakeCoin = StandardToken(_CakeCoin);
                CakeCoinOwner = _CakeCoinOwner;
        }

        function withdraw(uint withdraw_amount) public {

        // Limit withdrawal amount to 10 CakeCoin
        require(withdraw_amount <= 1000);

                // Use the transferFrom function of CakeCoin
                CakeCoin.transferFrom(CakeCoinOwner, msg.sender, withdraw_amount);
    }

        // REJECT any incoming ether
        function () public payable { revert(); }

}

```
这个合约的作用非常简单，就是接收CakeCoin，然后允许接收者提现到指定地址；

#### 修改migrate同时部署CakeCoin以及CakeCoinFaucet

因为CakeCoinFaucet依赖于CakeCoin合约的部署，所以我们修订之前的2_deploy_contracts.js为:

```
const CakeCoin = artifacts.require("CakeCoin");
const CakeCoinFaucet = artifacts.require("CakeCoinFaucet");

module.exports = function(deployer, network, accounts) {
  var owner = accounts[0];
  deployer.deploy(CakeCoin, {from:owner}).then(function(){
    // Then deploy CakeCoinFaucet and pass the address of CakeCoinToken  and the
    // address of the owner of all the CakeCoin who will approve CakeCoinFaucet
    console.log(CakeCoin.address);
    return deployer.deploy(CakeCoinFaucet, CakeCoin.address, owner);
  });
};

```

注意，CakeCoin部署完毕后，才能得到实际的合约地址，然后CakeCoinFaucet的合约部署需要传入这个地址；


#### 验证

首先看一下CakeCoin初始发币数目:

```
truffle(development)> let accounts;
truffle(development)> web3.eth.getAccounts((err,res) => { accounts = res });
truffle(development)> CakeCoin.deployed().then(instance => { instance.balanceOf(accounts[0]).then((balance) => console.log(balance.toString())) })
truffle(development)> 10000
```

看一下第二个测试地址的币:

```
truffle(development)> CakeCoin.deployed().then(instance => { instance.balanceOf(accounts[0]).then((balance) => console.log(balance.toString())) })
truffle(development)> 0
```

好了，我们先批准CakeCoinFaucet合约对CakeCoin的控制

```
truffle(development)> CakeCoin.deployed().then(instance => { instance.approve(CakeCoinFaucet.address, 10000) })
```

提现试一下:

```
truffle(development)> CakeCoinFaucet.deployed().then(instance => { faucet = instance})
truffle(development)> faucet.withdraw(1000, {from:web3.eth.accounts[1]})
truffle(development)> CakeCoin.deployed().then(instance => { instance.balanceOf(accounts[1]).then((balance) => console.log(balance.toString())) })
truffle(development)> 1000
```

#### 功能增强

翻阅[ERC20基类代码](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)可以发现，它其实没有什么神奇之处，只不过是把各个电子货币的名称、发行量、支持接口标准化了而已，其中最重要的增强就是为其它合约支持ERC20代币提供了两个接口approve和trnasfrom；

我们当然可以在ERC20的标准之上添加其它增强功能

##### 比如创始人可以随时销毁这个合约

```
contract owned {
      address payable owner;
      // Contract constructor: set owner
      constructor() public {
              owner = msg.sender;
      }
      // Access control modifier
      modifier onlyOwner {
             require(msg.sender == owner,
                     "Only the contract owner can call this function");
           _;
      }
}

contract CakeCoin is StandardToken, owned {
       // Contract destructor
       function destroy() public onlyOwner {
               selfdestruct(owner);
       }
}

```

##### 比如创始人可以销毁代币，或者增发代币

https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20Burnable.sol


##### 比如创始人可以临时终止代币的使用

https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20Pausable.sol

#### 甚至可以在某个合适的时间点对代币金融系统做个快照

https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20Snapshot.sol


#### 妖魔横行

我们用10行代码就创建了可以在技术层面媲美现代金融系统中最安全的电子货币，这一切是如此轻而易举，总觉得有哪些地方不大对劲~~~

是的，有的人认为这还是太麻烦了，最好有个web界面让我把币名、初始发行量、发行人等等信息填一下，最好加上两句蛊惑人心的宣传口号，然后一键发币~~

是的，这个要求很合理，于是诞生了像[ERC20-Generator](https://vittominacori.github.io/erc20-generator/) 这样的开源平台，它真正做到了让幼儿园小朋友也能一键发币！

只要填写几个简单的参数，在安装MetaMask的浏览器中支付一点ETH Gas费用，人人都可以发币；

光发个币自娱自乐的人非常少，我们在之前的文章里面一再提醒，所谓的区块链领域，充斥着诈骗赌博投机者；不幸的是，这帮人对于新技术的利用和孜孜不倦的学习精神让真正的专家们汗颜；很快的，他们就把这项技术应用在割韭菜事业中~~~


光发币还不足以割韭菜，还记得我们之前的介绍blockchain的文章吗？里面提到了比特币的[侧链](https://brain-zhang.github.io/blog/2019/01/23/bi-te-bi-de-blockchain-2/)技术，并预言基于Atomic Swap (原子交易)技术的交易所终将会大放光彩；

没错，以太坊作为技术急先锋试验场，诞生了像[Uniswap](https://uniswap.org/) 这样的平台，它是完全去中心化的，开源的，可以自动上架ERC20代币，向全世界的ETH玩家们敞开了投机大门、并且是完全公正，没有人控制的一个交易平台(当然，它有没有漏洞、是不是万无一失还很难说)~~~

人人都能发币，发行的货币可以毫无限制、毫无门槛的上架全世界交易流通的去中心化交易所，这就像是一个不受监管、零门槛的IPO市场，会发生什么就不用再多说了吧;

这是一个完全颠覆传统证券市场、传统赌博行业的一个新兴割韭菜基地；赌博投机者以其敢为人先的魄力，绝对的技术Geek范、对新技术的开放心态、野兽般的学习进取精神，还有绝妙的工程能力让人肃然起敬；


### 第四版(ERC223)

ERC20已经非常方便了，但是它还有一个明显的缺陷，就是把ERC20 Token发送到一个不支持它的合约B时，并不会报错，而是悄无声息的把这些Token冻结在B合约中，永远无法使用了；

在合约开发中，一般开发者们都会充分的考虑到接收ETH的处理，即使不能返还，也很少发生冻结ETH的问题；但是为ERC20 Token的使用者们所做的考虑却不多；作为一个开发者的角度来说，我怎么才能为无穷尽的ERC20 Token去做适配呢？ 那些傻瓜持有者们乱发到我的合约里算他们自己倒霉，有人在大街上乱撒钱然后收不回来，责任只能自己承担嘛；

在ICO群魔乱舞的时候，数不清的小白还没搞明白他们买到的Token到底是个什么东西，就迫不及待的充值各种合约，企图投机大赚一笔，这样做的结果就是有许多设计不当的投机合约冻结了大笔资金，并且.....没有人能取出来，即使你是这些合约的拥有者也无济于事；粗略估计这些小白们损失的资金在几百万美元的量级，可以参考：

https://github.com/ethereum/EIPs/issues/223


为了解决这个问题，有人非常贴心的提出了ERC223改进方案，思路也非常简单：

1. 实现ERC20 Token的时候，转账函数需要检测要发送的地址是不是有效的合约
2. 如果是有效的合约，需要调用一个约定好的函数(tokenFallback)看是否能处理我发送的Token

如果不满足以上两个条件，则转账失败，Token不会实际发送；

ERC223标准尚未被广泛采用，有关这个方案的后向兼容性、实现的形态到底是在合约接口层还是在用户界面等问题仍旧是以太坊社区讨论的焦点。


### 第五版(ERC777)

同样的针对ERC223提出的问题，另一个改进提案是ERC777:


ERC777除了要解决误把Token发给不支持的合约之外，还做了我们上文提到过的一些增强，比如:

* 为代币的生成和销毁提供特定事件。

* 使运营方（可信第三方，旨在验证合约）代表代币持有者移动代币。

* 在userData和operator数据字段中提供代币发送交易的元数据。

* 通过调用接收方的tokensReceived函数使合约和地址能够通知代币收据，并通过要求合约提供tokensReceived函数来降低代币被锁定到合约的可能性。

* 允许现有合约对tokensToSend和tokensReceived函数使用代理合约。

详细请参考：

http://github.com/ethereum/EIPs/issues/777

同样的，增强越多，实施就越慢，ERC777也还在社区讨论中......

注意，开发ERC777 Token上架UniSwap，如果代码处理不当，会有非常严重的安全风险，今年已经有无数Hack事件教用户做人了，请参考下面的最佳实践：

https://github.com/OpenZeppelin/exploit-uniswap


### 番外篇(ERC721)

当我们能随意发行代币之后，很容易就能扩展到金融行业另外的普遍需求，资产证券化；

最直观的就是我们之前的文交所、邮币卡之类的证券交易，还有房产证券化REITs等产品；而这些东西在智能合约的帮助下很容易实现；

可以预见，将来所有现实世界的融资手段或投机产品都能在区块链上找到对应的证券化模型；

好了，让我们看看如何将一件唯一的资产(比如名画)在智能合约上进行交易呢？


为了了解ERC20和ERC721的本质区别，我们只需要看一看ERC721的内部数据结构就可以了：

```
// Mapping from deed ID to ownermapping 
(uint256 => address) private deedOwner;
```

ERC20将所有者作为映射的主键，跟踪每个所有者的余额；而ERC721将合约ID作为映射的主键； 这样，我们只要创造一个智能合约，收录所有证券化的画作，并分配ID；就可以将其在链上进行交易了；

像ERC20规定了代币的标准化信息一样，ERC721也用一个Metadata提供了资产的标识信息，详细的实现请参考:

https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol


### 第六版(ERC1155)

到目前为止，我们已经为所有现实世界中拥有的证券化手段搬上了区块链，但是注意到了吗？这一切还有局限：

从ERC20到ERC721，每个提案都是根据区块链应用的一步步发展慢慢提出草案来标准化的；刚开始大家想的比较简单，就是一类资产对应一个合约；但很快，就有了更大的愿景，比如：

如何在一个合约中发行多个代币，或多项资产？

最典型的场景，我们开发了一款RPG游戏(暗黑破坏神)；里面充斥着大量的装备以及游戏金币，现在我们想要把这一切搬到区块链上，玩家们可以将金币Token化，从而交易各类装备；

按照现有的实现，我们需要发行一个Token合约，以及好几个装备合约；这样无疑会增加交易的复杂度以及Gas成本；

为了解决这类问题，有人提出了ERC1155，ERC1155借鉴了ERC20，ERC721和ERC777的全部思想；可以在一个合约中发行多个代币及资产，交易的时候可以批量完成多个交换：

https://github.com/ethereum/eips/issues/1155


老实说，这个合约的实现我还没有研究过，现在此类的应用也不多，让我们留到下次再探讨吧。


### 总结

最后，也许你已经被这些名词、规范、绕来绕去的工具链给搞晕了；那么我们只需要认清一件事，就是这个领域在高速的发展，今天被热捧的概念，也许明天就会被抛弃；在这种蛮荒时代，骗子层出不穷，要当心啊~~~
