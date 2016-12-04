git add -A
git commit -m “update”
git push origin code
echo "hexo push done"

hexo generate
cp -R public/* .deploy/
cd .deploy
git add -A
git commit -m “update”
git push origin master
echo "blog public push done"