
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

    git stash save -u
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

To clean up old deleted branchies in origin

    git remote prune origin
    
From Earle
----------

Do a commit of some interim stuff and then 

    git commit --amend

It extends the previous commit so you only have one.

Pull back the most recent commit into my workspace and let me do some more work on it.

    git reset Head~1

Do not add "--hard" otherwise things get thrown away.

Branching Notes from Noah
-------------------------

You probably have a local clone (A) of your fork (B) of the main repository (C). 
These are conventionally set up as remotes called origin (B) and upstream (C).

There is a new-ish feature of GitHub to synchronize a fork, which should be a button 
on the front page of your fork (B). But sometimes this doesn't show up (??), and 
you can do this the traditional way you're probably already familiar with:

	git checkout master
	git pull upstream master
	git push

Depending on a couple of settings you may also have to fetch upstream (C) to 
get a reference to the 11.x branch. It never hurts to do this (but you may already 
see the new branch because of the first pull):

	git fetch upstream

Then you checkout the branch locally and set it up to push to origin (B), so you 
can stay in sync with 11.x like you do master (first section here, just replace 
master with 11.x).

	git checkout 11.x
	git push -u origin 11.x

Then any feature/fix branches you want to target directly to 11.x (rather than into 
master and "backported") just use 11.x as the starting point:

	git checkout -b SAK-12345-feature-name 11.x
	# work
	git push -u origin SAK-12345-feature-name
	# make pull request

You can also do a sync-then-branch pattern if your muscle memory is like mine:

	git checkout 11.x
	git pull upstream 11.x
	git push
	git checkout -b SAK-12345-feature-name

One last detail... Strictly speaking, you would not *need* to push 11.x to your fork (B). 
You could leave it tracking upstream (C), but I find some value in maintaining the 
symmetry with master. That way, if you end up committing something to your local 11.x and 
push, we don't get accidental commits in upstream/11.x (C). It's a little bit more typing 
(git pull upstream 11.x instead of git pull) to stay updated, but for people 
who have the permissions to push to upstream but are not in the habit of doing 
branch management, I think it's a worthwhile investment. You can clean up your 
forked 11.x branch with relatively zero cost, whereas reverting commits or forcing 
pushes in upstream is ugly.

Happy branching!

Pulling Tags

git fetch -all
git tag -l
git checkout 11.0
