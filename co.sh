#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then 
    echo "Bad configuration or wrong shell"; 
    exit 
fi

echo Checking out from $GIT_REPO

# Do a full check out of all of the source
rm -rf trunk
git clone $GIT_REPO trunk

# Setting up the upstream master
if [ "$GIT_REPO" != "https://github.com/sakaiproject/sakai.git" ]; then 
    echo "Setting upstream master"
    cd trunk
    git remote add upstream https://github.com/sakaiproject/sakai
    cd ..
fi

