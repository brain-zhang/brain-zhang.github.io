---
layout: post
title: "elasticserach tips"
date: 2019-07-24 10:17:05 +0800
comments: true
categories: develop
---
elasticsearch升级到7.x；改动不小，命令从头再捋一遍；

PS:感叹elasticsearch在搜索和大数据聚合上面做的了不起的工作！ 细致入微，基本上在工程层面解决了数不清的细节问题，了不起的产品设计和再创造，了不起的工作量！ 就像docker重新唤醒容器技术一样，elasticsearch在Lucene之上的构建为个人数据分析和企业数据梳理开创新时代。 如果有条件，我是极为愿意买入他们的股票的。

<!-- more -->

## 文档操作

#### 增加一条记录


```
PUT /website/_doc/1
{
  "title": "My 2 blog entry",
  "text":  "I am starting to get the hang of this...",
  "date":  "2014/01/02"
}

```

#### 修改

```
POST /website/_update/1
{
   "doc" : {
      "tags" : [ "testing..." ],
      "views": 0
   }
}

```

#### 查询

```
GET /website/_search

GET /website/_source/1

GET /website/_mget 
{
    "ids" : [ "2", "1" ]    
}

GET /_search
{
    "query": YOUR_QUERY_HERE
}

```

#### 删除

```
DELETE /website/_doc/1

```

## 文档功能API

#### 获取映射信息

```
GET /website/_mapping

```

#### 测试分析器

```
GET /website/_analyze
{
  "field": "tweet",
  "text": "Black-cats" 
}

```

#### 多层级对象用扁平化的方法来存储，比如

```
{
  "gb": {
    "tweet": { 
      "properties": {
        "tweet":            { "type": "string" },
        "user": { 
          "type":             "object",
          "properties": {
            "id":           { "type": "string" },
            "gender":       { "type": "string" },
            "age":          { "type": "long"   },
            "name":   { 
              "type":         "object",
              "properties": {
                "full":     { "type": "string" },
                "first":    { "type": "string" },
                "last":     { "type": "string" }
              }
            }
          }
        }
      }
    }
  }
}


```
会被转换为如下内部对象:


```
{
    "tweet":            [elasticsearch, flexible, very],
    "user.id":          [@johnsmith],
    "user.gender":      [male],
    "user.age":         [26],
    "user.name.full":   [john, smith],
    "user.name.first":  [john],
    "user.name.last":   [smith]
}

```

#### 内部对象数组会丢失一部分相关信息，我们需要用嵌套对象(nested object)来处理

## 查询

#### 查询语句的结构

* 一个查询语句 的典型结构：

```
{
    QUERY_NAME: {
        ARGUMENT: VALUE,
        ARGUMENT: VALUE,...
    }
}

``` 

* 如果是针对某个字段，那么它的结构如下：

```
{
    QUERY_NAME: {
        FIELD_NAME: {
            ARGUMENT: VALUE,
            ARGUMENT: VALUE,...
        }
    }
}

```

* 一条复合语句

```
{
    "bool": {
        "must": { "match":   { "email": "business opportunity" }},
        "should": [
            { "match":       { "starred": true }},
            { "bool": {
                "must":      { "match": { "folder": "inbox" }},
                "must_not":  { "match": { "spam": true }}
            }}
        ],
        "minimum_should_match": 1
    }
}

```

#### 实战查询

* 精确查询

```
GET /website/_search
{
  "query": {
    "constant_score" : {
      "filter":{
        "term": {
          "title": "helloworld"
        }
      }
    }
  }
}

```

* 多词组合

```
GET /website/_search
{
    "query": {
        "match": {
            "title": {      
                "query":    "BROWN DOG!",
                "operator": "and"
            }
        }
    }
}

```

* 短语匹配

```
GET /website/_search
{
    "query": {
        "match_phrase": {
            "title": "quick brown fox"
        }
    }
}

```

* 混合短语匹配

```
GET /website/_search
{
    "query": {
        "match_phrase": {
            "title": {
                "query": "quick fox",
                "slop":  1
            }
        }
    }
}

```

* 正则查询 (性能慢)

```
GET /my_index/_search
{
    "query": {
        "wildcard": {
            "postcode": "W?F*HW" 
        }
    }
}

```

* 智能匹配

```
GET /my_index/_search
{
    "query": {
        "match_phrase_prefix" : {
            "brand" : {
                "query":          "johnnie walker bl",
                "max_expansions": 50
                }
        }
    }
}

```

* 控制精度

```
GET /website/_search
{
  "query": {
    "match": {
      "title": {
        "query":                "quick brown dog",
        "minimum_should_match": "75%"
      }
    }
  }
}

GET /website/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "title": "brown" }},
        { "match": { "title": "fox"   }},
        { "match": { "title": "dog"   }}
      ],
      "minimum_should_match": 2 
    }
  }
}

```

* 按受欢迎度提升权重

```
GET /blogposts/post/_search
{
  "query": {
    "function_score": { 
      "query": { 
        "multi_match": {
          "query":    "popularity",
          "fields": [ "title", "content" ]
        }
      },
      "field_value_factor": { 
        "field": "votes" 
      }
    }
  }
}

微调:
https://www.elastic.co/guide/cn/elasticsearch/guide/current/boosting-by-popularity.html

```

#### 排障

```
GET /website/_validate/query?explain
{
   "query": {
      "match" : {
         "text" : "really powerful"
      }
   }
}

```

#### 结果排序


```
GET /website/_search
{
    "query" : {
        "bool" : {
            "filter" : { "term" : { "_id" : 1 }}
        }
    },
    "sort": { "date": { "order": "desc" }}
}

```

## 索引操作

#### 增加

```
PUT /my_index
{
    "settings": { ... any settings ... },
    "mappings": {
        "type_one": { ... any mappings ... },
        "type_two": { ... any mappings ... },
        ...
    }
}

```


#### 删除

```
DELETE /my_index
DELETE /index_one,index_two
DELETE /index_*
DELETE /_all

```
#### 配置

* number_of_shards

每个索引的主分片数，默认值是 5 。这个配置在索引创建后不能修改。

* number_of_replicas

每个主分片的副本数，默认值是 1 。对于活动的索引库，这个配置可以随时修改。

#### 重新索引

```
POST _reindex
{
  "source": {
    "index": "twitter"
  },
  "dest": {
    "index": "new_twitter"
  }
}


```

#### 释放空间

```
POST /_all/_forcemerge?only_expunge_deletes=true

```
