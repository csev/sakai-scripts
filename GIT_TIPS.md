
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

Getting a diff of the most recent(1) commit

    git diff HEAD~1

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


Long Lived Development Branches
-------------------------------

How to work for a while in a development branch while staying in touch
with master so the merge always works and so you can pause for a moment
and fix a bug in master and get that merged.

In this example SAK-42 will be the development branch.

Prepare - catch local and fork up with master:

git checkout master
git pull upstream master
git push origin master

Lets start the dev branch:

get checkout -b SAK-42
# Start your work
git commit
git push origin SAK-42
# Do more work
git commit
git push origin SAK-42

Time passes - lets stay current with master:

git checkout master
git pull upstream master
git push origin master

git checkout SAK-42
git pull upstream master
git push origin SAK-42

Need to pause and fix SAK-1000:

git checkout master
git checkout -b SAK-1000
# Make fixes
git commit -a
git push origin SAK-1000

Once SAK-1000 it approved and merged into master - catch
both origin SAK-42 and origin master up using the
above commands.

Go back to working on SAK-42:

git checkout SAK-42
# Do more work
git commit
git push origin SAK-42


From Sam and Noah on the Feature Branch
---------------------------------------

Here is how I like to feel safe in my important feature branch:

# Make sure there is a copy of my feature branch if things go really terrible
git push origin feature-branch

# Pull all updates from Github
git fetch --all

# Now attempt to rebase my feature branch with the upstream changes
# I may need to resolve conflicts if someone else is editing the same files
git rebase upstream/master

# to prefer upstream master use this
git rebase -Xours upstream/master

# If all is good, I can update Github against with my changes
# This needs --force per Noah
git push --force origin SAK-xxx

# Added by Chuck
git checkout master
git push origin master
git checkout feature-branch


Noah Notes

Now, my editorial on when to do repeated merges to your branch and when to rebase...

Basically, the more involved the change and the longer the timeframe, the less likely a rebase is going to work smoothly. The reason is that you have to roll the new base commit (say tip of master) through all of your commits. In some situations where you are changing the same area in step fashion, you have to reconcile current master with every stage of your branch. You can't make it like it should be now that you have seen the final answer, but show your work all the way through from a different starting point.

My rule of thumb is that if I'm messing with a rebase for more than 10 minutes, I cut bait and fish elsewhere with a plain merge of latest master to the top of my branch. That merge may still be complicated, but it's one shot. Reconcile the latest of both, and it's ready to merge... no chance of maybe needing to resolve through 10 more intermediate commits.

I prefer to rebase but I bail out pretty quickly if it goes wacky.

Notes on merges
---------------

git reset --hard origin/master

git merge -s recursive -X ours
git merge -s recursive -X theirs


Switching from 25.x to 23.x (From Sharadhi and Shivangi)
--------------------------------------------------------

1. sakai-scripts/trunk — bash stop.sh (ctrl +c on the tail and stop the server)
2. sakai-scripts/trunk — git status
3. sakai-scripts/trunk — git fetch - -all
4. sakai-scripts/trunk — git checkout 23.x
5. sakai-scripts/trunk — git log
6. Exit git log with “q”
7. Go to GitHub on your forked Sakai repository, and check for the 23.x branch under the
branches tab. Your repo now is up-to-date 23.x with Sakai’s 23.x

sakai-scripts/trunk — git remote -v
9. sakai-scripts/trunk — git push origin 23.x
10. sakai-scripts/trunk — Do a cd ../ to go to sakai-scripts repo
   
11. sakai-scripts — diff sakai.properties apache-tomcat-9.0.2/sakai/sakai.properties
(just to check if there’s been any misalignment between your sakai.properties and the one in Apache)
12. sakai-scripts — bash na.sh (to start a fresh Tomcat instance)
13. sakai-scripts — bash qmv.sh (to recompile everything and fill up your Tomcat)
14. sakai-scripts — bash start.sh and bash tail.sh
15. sakai-scripts/trunk — git status (You should be on 23.x with the message “Your branch is
up to date with upstream/23.x”. If you don’t see this, do a git checkout 23.x)
16. Make your code changes and then create a new branch as mentioned in step 18.
17. sakai-scripts/trunk — smv (to compile your changes)
18. sakai-scripts/trunk — git checkout -b SAK-number
19. sakai-scripts/trunk — git commit -am “SAK-number with a message”
20. sakai-scripts/trunk — git push origin SAK-number
21. Now go to GitHub, go to the branches tab, and find your new branch.
22. Click on Contribute and open a pull request.

23. Change base: master to 23.x

Switching from 23.x to 25.x
1. sakai-scripts/trunk — git checkout SAK-number (This SAK-number can be anything that you were previously working on 25.x. You don’t have to switch to master first.)
2. sakai-scripts/trunk — git status (to verify you have switched to your previous 25.x branch)
3. sakai-scripts/ —- Stop the tail with ctrl + c and stop the server with bash stop.sh.
4. sakai-scripts/ — bash na.sh
5. sakai-scripts/ — bash qmv.sh (after everything compiles, your Apache and codebase will
now switch back to 25.x)

