#! /bin/bash
source config-dist.sh
if [ "$PORT" == "" ]; then 
    echo "Bad configuration or wrong shell"; 
    exit 
fi

echo Checking out from $GIT_REPO

# Do a full check out of all of the source
rm -rf trunk
git clone $GIT_REPO trunk

