Start-GitConnection

mkdir foo
cd foo
mkdir test
cd test
git init
"test" >>test.txt
git add .
git commit -m "test commit"
git push ../repo.git master

cd ..
mkdir repo.git
cd repo.git
git init --bare

cd ..
git clone repo.git receive

cd repo.git\hooks
@"
#!/bin/sh

# . /home/username/repo.git/hooks/post-receive
echo "test post-receive"

# -----------------------
#powershell sample
# -----------------------
whoami
pwd
cd hooks
C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy RemoteSigned -File .\\AutoPull_test.ps1

# -----------------------
#bash sample
# -----------------------
#pwd # post-receive‚ªŽÀs‚³‚ê‚é‚Æ‚«‚Írepo.git/‚É‚¢‚é
#cd ..
#cd receive # --git-dir‚ðÝ’è‚·‚é‚½‚ß‚ÉˆÚ“®‚·‚é
#pwd
#git --git-dir=.git pull ../repo.git master
"@ | Set-Content .\post-receive


@"
#Import-Module PS-GitHub
cd ..\..\receive
pwd
git --git-dir=.git pull ..\\repo.git master
exit
"@ | Set-Content .\AutoPull_test.ps1

cd ..\..\
@"
cd test
"hoge" >>.\test.txt
git add .
git commit -m "test commit for local hook"
git push ..\repo.git master
"@ | Set-Content .\git_commnad.ps1

.\git_commnad.ps1

Read-Host