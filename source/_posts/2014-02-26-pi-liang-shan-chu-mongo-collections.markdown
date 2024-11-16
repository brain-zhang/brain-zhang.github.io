---
layout: post
title: "批量删除mongo collections"
date: 2014-02-26 17:24:04 -0800
comments: true
categories: mongodb tools
---

mongodb没有批量删除collecton的命令，平常建立了很多a1,a2,a3的表删除有些麻烦，写个小脚本方便些。

    mongorm.sh -d database -c a*

就很方便删除了。

    #!/bin/bash
    # remove mongodb's collections with command "mongn rm app*"
    # Usage `mongorm <-c collections*> <-d dababase>`

    E_BADARGS=85
    E_NOFILE=86

    DATABASE=''
    COLLECTIONS=''

    while getopts "c:d:h" arg
    do
            case $arg in
                 c)
                    echo "-c $OPTARG"
                    COLLECTIONS=$OPTARG
                    ;;
                 d)
                    echo "-d $OPTARG"
                    DATABASE=$OPTARG
                    ;;
                 h)
                     echo "mongorm <-d database> <-c collections>"
                     echo "for exp:"
                     echo "        mongorm -d bpc -c app*"
                     ;;
                 ?)
                    echo "unkonw argument"
            exit 1
            ;;
            esac
    done

    if [[ -z "$DATABASE" ]]
        # Correct number of arguments passed to script?
    then
        echo 'Usage: -d database'
        echo 'please do mongorm.sh -h to get more info'
        exit $E_BADARGS
    fi

    if [[ -z "$COLLECTIONS" ]]
        # Correct number of arguments passed to script?
    then
        echo 'Usage: -c collections'
        echo 'please do mongorm.sh -h to get more info'
        exit $E_BADARGS
    fi

    mongojs_rm_function=`cat << EOF
    db.getCollectionNames().forEach(function(c) {
        if(c.match("$COLLECTIONS")) {
                    db.getCollection(c).drop();
                        }
                      });
    EOF
    `
    echo $mongojs_rm_function>remove.js

    mongo 127.0.0.1:27017/$DATABASE remove.js
    rm -rf remove.js
