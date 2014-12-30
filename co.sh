#! /bin/sh
source config-dist.sh

echo $GIT_REPO

exit
# Do a full check out of all of the source
svn co $GIT_REPO trunk

