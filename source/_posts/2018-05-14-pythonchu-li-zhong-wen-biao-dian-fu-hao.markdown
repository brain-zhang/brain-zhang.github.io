---
layout: post
title: "Python处理中文标点符号"
date: 2018-05-14 09:03:13 +0800
comments: true
categories: develop
---

中文文本中可能出现的标点符号来源比较复杂，通过匹配等手段对他们处理的时候需要格外小心，防止遗漏。以下为在下处理中文标点的时候采用的两种方法:

<!-- more -->

### 中文标点集合

#### 比较常见标点有这些：


```
！？｡＂＃＄％＆＇（）＊＋，－／：；＜＝＞＠［＼］＾＿｀｛｜｝～｟｠｢｣､、〃》「」『』【】〔〕〖〗〘〙〚〛〜〝〞〟〰〾〿–—‘’‛“”„‟…‧﹏.

```

调用zhon包的zhon.hanzi.punctuation函数即可得到这些中文标点。

如果想用英文的标点，则可调用string包的string.punctuation函数可得到：


```
!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~

```

因此，比如需要将所有标点符号去除，可以进行以下操作：


```
>>> import re
>>> from zhon.hanzi import punctuation
>>> line = "测试。。去除标点。。"
>>> print re.sub("[{}]+".format(punctuation), "", line.decode("utf-8")) # 需要将str转换为unicode

```

当然，如果想去除重复的符号而只保留一个，那么可以用\1指明：比如


```
>>> re.sub(ur"([{}])+".format(punctuation), "\1", line.decode("utf-8"))

```

你也可以手工指定这些标点符号


```
punctuation = """！？｡＂＃＄％＆＇（）＊＋－／：；＜＝＞＠［＼］＾＿｀｛｜｝～｟｠｢｣､、〃》「」『』【】〔〕〖〗〘〙〚〛〜〝〞〟〰〾〿–—‘’‛“”„‟…‧﹏"""
re_punctuation = "[{}]+".format(punctuation)
line = re.sub(re_punctuation, "", line)

```

### 可以通过直接指定unicode码范围的办法来strip，比如:

去除所有半角全角符号，只留字母、数字、中文


```
def remove_punctuation(line):
    rule = re.compile(ur"[^a-zA-Z0-9\u4e00-\u9fa5]")
    line = rule.sub('',line)
    return line

```

汉字的范围为”\u4e00-\u9fa5“，这个是用Unicode表示的，所以前面必须要加”u“；字符”r“的意思是表示忽略后面的转义字符，这样简化了后面正则表达式里每遇到一个转义字符还得挨个转义的麻烦


### 最后可以组合成为一个函数


```
def remove_punctuation(line, strip_all=True):
    if strip_all:
        rule = re.compile(ur"[^a-zA-Z0-9\u4e00-\u9fa5]")
        line = rule.sub('',line)
    else:
        punctuation = """！？｡＂＃＄％＆＇（）＊＋－／：；＜＝＞＠［＼］＾＿｀｛｜｝～｟｠｢｣､、〃》「」『』【】〔〕〖〗〘〙〚〛〜〝〞〟〰〾〿–—‘’‛“”„‟…‧﹏"""
        re_punctuation = "[{}]+".format(punctuation)
        line = re.sub(re_punctuation, "", line)

    return line.strip()

```

### 清洗完毕后，有时候我们希望按照多个标点符号来分割

比如只要遇到中文或英文的逗号和句号等符号就分割，可以直接用translate把这些符号翻译为统一的分隔符，再split:


```
strip_chars = '？"。.，,《》[]〖〗“”'
single_line = single_line.translate(str.maketrans(dict.fromkeys(strip_chars, '#')))
single_line = single_line.split('#')

```


