
Sakai GIT Documentation

https://confluence.sakaiproject.org/display/SAKDEV/Git+Setup

Making a branch 

    git checkout SAK-12345

Switching to a branch

    git checkout master

Syncing to your local repo

    git pull upstream master
    git push origin master

Working on a JIRA in your fork - One Commit becomes a Pull Request

    git checkout -b SAK-29331
    git commit ...
    git push origin SAK-29331

Go to your fork in github, go to the branch and submit a PR
Make sure that your branch is sending to sakaiproject/sakai/master
Press "Create Pull Request"
Wait for the Travis Build to compete - might take an hour

After Travis Finishes, merge the PR and delete the branch

    git checkout master   (switch back to your master)
    git pull upstream master (catchup with sakai main repo)
    git push origin master (Make sure your repo is caught up)
    

