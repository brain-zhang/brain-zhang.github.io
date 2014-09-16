#/bin/bash
bundle exec rake generate
git add .
git ci -a -m "memorybox"
git push origin source -f
bundle exec rake deploy
