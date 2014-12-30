#! /bin/bash
#
# This automates the steps to checkout and build Sakai.
source config-dist.php

# Do it all!
# Clean out the repo so any unbuilt artifacts will need to be downloaded
rm -rf ~/.m2/repository/org/sakaiproject
# make a fresh copy of Tomcat
bash na.sh
# Check out all of the Sakai source
bash co.sh
# Compile it all, capturing the log
bash qmv.sh | tee /tmp/qmv.out
# Check for Sakai artifacts that were not built
egrep 'Downloading.*\/sakaiproject|====' /tmp/qmv.out | grep -v plugins | sed 's/.*Downloading/Downloading/'
