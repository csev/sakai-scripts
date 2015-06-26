
https://confluence.sakaiproject.org/display/SAKDEV/Git+Setup

Note: Local changes (i.e. what you see with "git diff") are just hanging
around - they dont care what branch you are in - they are only local 
until you do a commit to a particular branch.

You can limit the scope of several commands to "the current folder and below"
as follows:

    git diff .
    git commit .

Making a branch 

    git checkout -b SAK-12345

Gitting a diff from already committed changes.  Do a 

    git log

Find the commit sha and then:

    git diff 74fb...b752^ 74fb...b752

Switching to a branch

    git checkout master

Syncing to your local repo

    git pull upstream master
    git push origin master

Stashing

    git stash
    git stash list
    git show stash@{0}
    git stash apply stash
    git stash apply stash@{1}
    

Working on a JIRA in your fork - One Commit becomes a Pull Request

    git checkout master
    git checkout -b SAK-29331
    git commit ...
    git push origin SAK-29331

Squashing several un-pushed commits before pushing them as one commit

    git checkout master
    git checkout -b SAK-29331
    git commit ...
    git commit ...
    git commit ...
    git reset --soft HEAD~3
    git commit ...
    git push origin SAK-29331

To submit a PR, go to your fork in github, go to the branch 
and submit a PR Make sure that your branch is sending to 
sakaiproject/sakai/master - Press "Create Pull Request"
Wait for the Travis Build to compete - might take an hour

After Travis Finishes, merge the PR and delete the branch

    git checkout master   (switch back to your master)
    git pull upstream master (catchup with sakai main repo)
    git push origin master (Make sure your repo is caught up)
    
Squashing multiple commits in a branch into one:

    git rebase -i master
    git push --force origin SAK-12345

I think that if you dont include the "-i master", it
will want to catch master up.

To delete a borked branch:

    git checkout master
    git branch -d SAK-29531
    git branch -D SAK-29531
    git push origin :SAK-29531

