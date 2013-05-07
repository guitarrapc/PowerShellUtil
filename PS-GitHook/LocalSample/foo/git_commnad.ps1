cd test
"hoge" >>.\test.txt
git add .
git commit -m "test commit for local hook"
git push ..\repo.git master
