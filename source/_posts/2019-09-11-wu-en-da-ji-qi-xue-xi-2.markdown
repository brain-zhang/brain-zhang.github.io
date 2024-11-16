---
layout: post
title: "吴恩达机器学习笔记-2"
date: 2019-09-11 10:53:38 +0800
comments: true
categories: develop ai
---

Logistic回归， 正则化
{:.info}

<!-- more -->


## 1-Logistic回归

#### 分类

逻辑回归 (Logistic Regression)是分类问题的一个代表算法，这是目前最流行使用最广泛的一种学习算法。

我们将因变量(dependant variable)可能属于的两个类分别称为负向类（negative class）和 正向类（positive class），则因变量  𝑦∈0,1 ，其中 0 表示负向类，1 表示正向类。

分类问题下，可以采用逻辑回归的分类算法，这个算法的性质是：它的输出值永远在 0 到 1 之间。 它适用于标签 y 取值离散的情况，如：1 0 0 1。

#### 假设陈述

分类问题，希望分类器的输出值在 0 和 1 之间，因此，假设函数需要满足预测值要在 0 和 1 之间。

回归模型的假设是：

$$
h_\theta(x)=g(\theta^TX)
$$

其中：

* X 代表特征向量

* g 代表逻辑函数（logistic function）, 是一个常用的逻辑函数为 S形函数（Sigmoid function），公式为：

$$
g(z) = \frac{1}{1+e^{-z}}
$$

* python 代码实现sigmoid函数：

```
import numpy as np
def sigmoid(z):
    return 1 / (1 + np.exp(-z))
```

结合起来，获得逻辑回归的假设：

$$
h_\theta(x) =  \frac{1}{1+e^{-\theta^TX}}
$$

𝜃(𝑥) 的作用是，对于给定的输入变量，根据选择的参数计算输出变量为1 的可能性 （estimated probablity），即  ℎ𝜃(𝑥)=𝑃(𝑦=1|𝑥;𝜃) 。


#### 代价函数

逻辑回归的代价函数为：

$$
J(\theta)= \frac{1}{m}\sum^m_{i=1}Cost(h_\theta(x^{(i)}), y^{(i)})
$$

其中:

$$
Cost(h_\theta(x), y)=-y\times{log(h_\theta(x))}-(1-y)\times{log(1-h_\theta(x))}
$$

代入代价函数:

$$
J(\theta) = -\frac{1}{m}\sum^m_{i=1}[y^{(i)}log(h_\theta(x^{(i)}))+(1-y^{(i)})log(1-h_\theta(x^{(i)}))]
$$

* 逻辑回归代价函数的Python代码实现：

```
import numpy as np
def cost(theta, X, y):
    theta = np.matrix(theta)
    X = np.matrix(X)
    y = np.matrix(y)
    first = np.multiply(-y, np.log(sigmoid(X * theta.T)))
    second = np.multiply((1 - y), np.log(1 - sigmoid(X * theta.T)))
    return np.sum(first - second) / (len(X))
```

#### 简化代价函数和梯度下降

$$
\theta_j := \theta_j - \alpha \frac{1}{m}\sum^m_{i=1}(h_\theta(x^{(i)})-y^{(i)})x^{(i)}_j
$$

这个更新规则和之前用来做线性回归梯度下降的式子是一样的， 但是假设的定义发生了变化。即使更新参数的规则看起来基本相同，但由于假设的定义发生了变化，所以逻辑函数的梯度下降，跟线性回归的梯度下降实际上是两个完全不同的东西。


#### 多分类任务 一对多

邮件归类， 假如说你现在需要一个学习算法能自动地将邮件归类到不同的文件夹里，区分开来自工作的邮件、来自朋友的邮件、来自家人的邮件或者是有关兴趣爱好的邮件，那么，就有了一个四分类问题：其类别有四个，分别用 y=1、y=2、y=3、y=4 来代表。

多分类的关键就是构建多个逻辑分类函数；具体：

我们将多个类中的一个类标记为正向类（y=1），然后将其他所有类都标记为负向类，这个模型记作 ℎ(1)𝜃(𝑥)。接着，类似地第我们选择另一个类标记为 正向类（y=2），再将其它类都标记为负向类，将这个模型记作  ℎ(2)𝜃(𝑥) ,依此类推。 最后我们得到一系列的模型简记为：

$$
h^{(i)_\theta(x)} = p(y=i|x;\theta)
$$

最后，在我们需要做预测时，我们将所有的分类机都运行一遍，然后对每一个输入变量，都选择最高可能性的输出变量。 总之，我们已经把要做的做完了，现在要做的就是训练这个逻辑回归分类器： ℎ(𝑖)𝜃(𝑥) ， 其中 i对应每一个可能的y=i，最后，为了做出预测，我们给出输入一个新的 x 值做预测。我们要做的就是在我们三个分类器里面输入 x，然后我们选择一个让  ℎ(𝑖)𝜃(𝑥) 最大的 i，即

$$
\max_ih^{(i)_\theta(x)}
$$

##  2-正则化

#### 过拟合问题

就以多项式理解，x 的次数越高，拟合的越好，但相应的预测的能力就可能变差。

如何解决？

* 丢弃一些不能帮助我们正确预测的特征。可以是手工选择保留哪些特征，或者使用一些模型选择的算法来帮忙（例如 PCA, LDA），缺点是丢弃特征的同时，也丢弃了这些相应的信息；

* 正则化。 保留所有的特征，但是减少参数的大小（magnitude），当我们有大量的特征，每个特征都对目标值有一点贡献的时候，比较有效。

* 还有一个解决方式就是增加数据集,因为过拟合导致的原因就过度拟合测试数据集, 那么增加数据集就很大程度提高了泛化性了.


#### 代价函数

正则化的基本方法：对高次项添加惩罚值，让高次项的系数接近于0。

假如我们有非常多的特征，我们并不知道其中哪些特征我们要惩罚，我们将对所有的特征进行惩罚，并且让代价函数最优化的软件来选择这些惩罚的程度。这样的结果是得到了一个较为简单的能防止过拟合问题的假设：

$$
J(\theta) = \frac{1}{2m} [ \sum_{i=1}^m(h_{\theta}(x^{(i)})-y^{(i)})^{2} + \lambda\sum_{j=1}^n\theta^2_j  ]
$$

其中 𝜆 又称为正则化参数（Regularization Parameter）


```
import numpy as np
def mseWithRegular(predict, y, w, lmd=0.1):
    '''
        predict: 模型输出
        y: 真实标签
        w: 模型权重
        lmd: 正则化参数
    '''
    constrct_loss = np.sum((predict - y) ** 2)
    experience_loss = lmd * np.sum(w ** 2)
    loss = (constrct_loss + experience_loss) / (2 * len(predict))
    return loss

predict = np.array([1, 1.5, 2])
y = np.array([0.9, 1.4, 2.1])
w = np.array([[1], [1], [1]])
mseWithRegular(predict, y, w)
```

如果选择的正则化参数 𝜆 过大，则会把所有的参数都最小化了，导致模型变成  ℎ𝜃(𝑥)=𝜃0 ，造成欠拟合。

所以对于正则化，我们要取一个合理的λ的值，这样才能更好的应用正则化。

#### 线性回归正则化
对于线性回归的求解，我们之前推导了两种学习算法：一种基于梯度下降，一种基于正规方程

正则化线性回归的代价函数为：

$$
J(\theta) = \frac{1}{2m} [ \sum_{i=1}^m(h_{\theta}(x^{(i)})-y^{(i)})^{2} + \lambda\sum_{j=1}^n\theta^2_j ]
$$

* 梯度下降使代价函数最小化

$$
\theta_j := \theta_j (1-a\frac{\lambda}{m})- \alpha \frac{1}{m}\sum^m_{i=1}(h_\theta(x^{(i)})-y^{(i)})x^{(i)}_j
$$


* 正规方程来求解正则化线性回归模型

TODO: 暂时没有理解

#### 逻辑回归正则化

针对逻辑回归问题，我们在之前的课程已经学习过两种优化算法：梯度下降法，更高级的优化算法需要你自己设计代价函数 𝐽(𝜃) 。

给代价函数增加一个正则化的表达式，得到代价函数:

$$
J(\theta) = \frac{1}{m}\sum^m_{i=1}[-y^{(i)}log(h_\theta(x^{(i)}))-(1-y^{(i)}log(1-h_\theta(x^{(i)}))]+\frac{\lambda}{2m}\sum_{j=1}^n\theta^2_j
$$

代码实现:

```
import numpy as np
def sigmoid(x, derivative=False):
    sigm = 1. / (1. + np.exp(-x))
    if derivative:
        return sigm * (1. - sigm)
    return sigm

def costReg(theta, X, y, learningRate):
    theta = np.matrix(theta)
    X = np.matrix(X)
    y = np.matrix(y)
    first = np.multiply(-y, np.log(sigmoid(X * theta.T)))
    second = np.multiply((1 - y), np.log(1 - sigmoid(X * theta.T)))
    reg = (learningRate / 2 * len(X)) * np.sum(np.power(theta[:,1:theta.shape[1]], 2))
    return np.sum(first - second) / (len(X)) + reg
```

最后，它的梯度下降看上去同正则化的线性回归一样，但是由于假设ℎ𝜃(𝑥)=𝑔(𝜃𝑇𝑋) ，所以与线性回归不同。
