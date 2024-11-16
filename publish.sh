#/bin/bash

# image url(put images folders of branch source):
# ![img](https://raw.githubusercontent.com/brain-zhang/brain-zhang.github.io/source/images/20191106/bg0.png)

# list
# * list element with functor item{:toc}

#cd _deploy && git pull && cd ../
bundle exec rake generate
#echo "happy123.me" > public/CNAME
bundle exec rake deploy
git add .
git commit  -m "$1"
git push origin source
