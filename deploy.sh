#!/bin/bash

# push code branch
git add -A
git commit -m “update”
git push origin code
echo "hexo push done"

# clean .deploy
mkdir -p .deploy
cd .deploy
shopt -s extglob
rm -rf !(README.md|.gitignore|.git)
cd ..

# copy public to .deploy
hexo clean
hexo generate
cp -r public/* .deploy/
cp CNAME .deploy/

# push master branch
cd .deploy
git add -A
git commit -m “update”
git push origin master
echo "blog public push done"