---
layout: post
title: "enable ldap on centos"
date: 2016-05-25 08:24:04 +0800
comments: true
categories: centos ldap tools
---

## Dockerfile


    FROM docker-registry.dev.netis.com.cn:5000/autobuild/centos6

    # Maintainer: docker_user <docker_user at email.com> (@docker_user)
    MAINTAINER memoryboxes memoryboxes@gmail.com

    # Commands to add ldap to image
    RUN mkdir -p /etc/openldap/cacerts/ && \
        rpm --rebuilddb && \
        yum clean all  && \
        wget http://xxxxxx/ca.cert -O /etc/openldap/cacerts/ca.cert && \
        wget http://xxxxxx/sshd_config -O /etc/ssh/sshd_config && \
        chmod 600 /etc/ssh/sshd_config && \
        sed -i  's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config && \
        echo "xxxxxxx" | passwd --stdin root && \
        yum -y install pam_ldap.so authconfig nscd openldap-clients nss-pam-ldapd && \
        yum -y install sudo && \
        yum clean all

    ADD nscd /etc/dockerservices/nscd
    ADD nslcd /etc/dockerservices/nslcd
    COPY docker_entrypoint.sh /

    # Commands when creating a new container
    ENTRYPOINT ["/docker_entrypoint.sh"]
    CMD ["/usr/bin/svscan", "/etc/dockerservices"]


## docker_entrypoint.sh

    #!/bin/bash

    set -e

    echo "x.x.x.x ldap.xxx.com.cn" >>/etc/hosts
    authconfig --enableldap --enableldapauth --ldapserver=ldap.xxx.com.cn --ldapbasedn="dc=xxx,dc=com,dc=cn" --enablemkhomedir --enableldaptls --enablecache

    exec "$@"
