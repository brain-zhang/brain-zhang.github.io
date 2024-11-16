---
layout: post
title: "How to allow non-root process to bind to low-numbered ports"
date: 2021-06-01 16:32:31 +0800
comments: true
categories: tools
---

#### Use CAP_NET_BIND_SERVICE to grant low-numbered port access to a process:

With this you can grant permanent access to a specific binary to bind to low-numbered ports via the setcap command:

```
sudo setcap CAP_NET_BIND_SERVICE=+eip /path/to/binary
```

For more details on the e/i/p part, see cap_from_text.

After doing this, /path/to/binary will be able to bind to low-numbered ports. Note that you must use setcap on the binary itself rather than a symlink.


FROM:

https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
