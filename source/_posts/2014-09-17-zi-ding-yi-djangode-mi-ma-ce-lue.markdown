---
layout: post
title: "自定义Django的密码策略"
date: 2014-09-17 08:38:03 +0800
comments: true
categories: Django
---
Django 从1.4 版本开始，包含了一些安全方面的重要提升。其中一个是使用 PBKDF2 密码加密算法代替了 SHA1 。另外一个特性是你可以添加自己的密码加密方法。

Django 会使用你提供的第一个密码加密方法（在你的 setting.py 文件里要至少有一个方法）

```
PASSWORD_HASHERS = (
    'django.contrib.auth.hashers.PBKDF2PasswordHasher',
    'django.contrib.auth.hashers.PBKDF2SHA1PasswordHasher',
    'django.contrib.auth.hashers.BCryptPasswordHasher',
    'django.contrib.auth.hashers.SHA1PasswordHasher', # Insecure Hashes
    'django.contrib.auth.hashers.MD5PasswordHasher', # Insecure Hashes
    'django.contrib.auth.hashers.CryptPasswordHasher', # Insecure Hashes
)
```

但Django默认生成的密码策略往往会带上 md5_xxx, pbkdf2_xxx，同其他系统整合的时候，一般是没有这些前缀的，这就需要我们自定义一个密码策略。

下面介绍下如何定义一个简单的 `md5(md5(password, salt))` 密码策略。

###step1

建立一个app，django-admin.py startapp ownmd5

###step2

在 ownmd5中 建立 hashers.py 文件，加入 OwnMd5PasswordHasher 类

```
import hashlib
from django.utils.translation import ugettext_noop as _
from django.utils.datastructures import SortedDict
from django.utils.crypto import constant_time_compare
from django.utils.encoding import force_bytes, force_str, force_text
from django.contrib.auth.hashers import BasePasswordHasher, mask_hash


class OwnMD5PasswordHasher(BasePasswordHasher):
    """
    The Salted MD5 password hashing algorithm (not recommended)
    """
    algorithm = "ownmd5"

    def encode(self, password, salt):
        assert password is not None
        assert salt and '$' not in salt
        hash = hashlib.md5(hashlib.md5(force_bytes(salt + password)).hexdigest()).hexdigest()
        return hash

    def verify(self, password, encoded, salt):
        encoded_2 = self.encode(password, salt)
        return constant_time_compare(encoded, encoded_2)

    def safe_summary(self, encoded, salt):
        return SortedDict([
            (_('algorithm'), self.algorithm),
            (_('salt'), mask_hash(salt, show=4)),
            (_('hash'), mask_hash(hash)),
        ])
```
###step3

将 OwnMD5PasswordHasher 加入到settings.py 中:
```
PASSWORD_HASHERS = (
    'ownmd5.hashers.OwnMD5PasswordHasher',
)
```
这样，默认的user及auth模块都会采用自定义的md5算法。

参考:

https://docs.djangoproject.com/en/1.6/topics/auth/passwords/
