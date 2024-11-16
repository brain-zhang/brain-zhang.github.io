---
layout: post
title: "How to setup your ownAI with ollama"
date: 2023-12-16 17:39:58 +0800
comments: true
categories: develop ai
---

AI大潮汹涌，一年时间，各种大模型层出不穷；用多了ChatGPT，自然想要自己本地搭建一个，看看单机版大模型的表现如何；

目前最简单的，还是用ollama，简单记录一下本地搭建流程。

<!-- more -->


#### 硬件

垃圾党配置:

* CPU: E5 2680V2
* 内存: 64GB
* 显卡: GTX3060

如果要运行一个7B的模型，这个配置可以满足比较简单的问答了，一般一分钟内能出100个Token

但如果要运行一个13B的模型，无论如何都要上3090了;


#### 软件配置

ubuntu20.04LTS + NVIDIA-SMI 525.147.05 + CUDA11.3


#### 搭建过程

1. 安装ollama

```
curl https://ollama.ai/install.sh | sh
```

2. 修改配置文件，开放对外服务

```
vim /etc/systemd/system/ollama.service


# 增加环境变量
iEnvironment=OLLAMA_HOST=0.0.0.0
Environment=OLLAMA_ORIGINS=*


# 重启服务

systemctl daemon-reload
systemctl restart ollama
```

3. 搭建一个web UI

```
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway --name ollama-webui --restart always ghcr.io/ollama-webui/ollama-webui:main
```

此时就可以用 `http://x.x.x.x:3000` 这个地址访问AI服务了

4. 下载模型

我实验下来，有两个模型还是可以的，就是 llvma2和dolphin-mixtral,但是他们的中文能力都不怎么样，英文表现好一点

```
ollama pull llama2:latest
ollama pull dolphin-mixtral:latest
```


#### 性能

Token输出速度还是可以的，一般问答一分钟都可以输出；这个时候3060 12GB显存基本上满载了；


#### 表现

只能说，如果一年前本地跑模型能达到这个水平，那我会震惊；

但是现在用多了ChatGPT4V；只能说差得远；不能用作生产，只能个人娱乐；

听说现在当红的 `mixtral-8x7`表现很不错，但是这个模型至少需要A100级别才能跑起来；暂时没有这种条件，只能看着人家搞流口水......

AGI，已经变成超重资产行业了...


