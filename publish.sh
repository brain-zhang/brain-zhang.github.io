#/bin/bash
bundle exec rake generate
git add .
git ci -a -m "memorybox"
git push origin source
bundle exec rake deploy
