#/bin/bash
bundle exec rake generate
git add .
git ci -a -m "memorybox"
bundle exec rake deploy
git push origin source -f
