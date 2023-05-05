#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then 
    echo "Bad configuration or wrong shell"; 
    exit 
fi

if [ $# -eq 1 ]
  then
    GIT_REPO=$1
fi

# Do a full check out of all of the source

if [ -d "trunk" ]; then
  tfile="$(mktemp -d /tmp/old-trunk-XXXXXXXXX)"
  echo "Removing trunk folder...."
  mv trunk $tfile
  rm -rf trunk
  rm -rf /tmp/old-trunk-* &
fi

echo Checking out from $GIT_REPO ...
git clone $GIT_REPO trunk
if [ ! -d "trunk" ]; then
   echo "Checkout failed."
   exit
fi

# Setting up the upstream master
if [ "$GIT_REPO" != "https://github.com/sakaiproject/sakai.git" ]; then 
    echo "Setting upstream master"
    cd trunk
    git remote add upstream https://github.com/sakaiproject/sakai
    cd ..
else
    echo " "
    echo "You checked out the Sakai Repository - you may not be able to"
    echo "Do a git push.  You probably should fork the sakai repository"
    echo "and set up config.sh to point to your forked repository."
fi

