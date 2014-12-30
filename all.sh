#! /bin/sh
#
# This automates the steps to checkout and build Sakai.
#
# It is provided more as an example starting point for 
# a nightly process rather than something to use when setting
# up a dev instance of Sakai.   It creates an HSQLDB instance,
# where most developers should make a MySQL instance
# which requires manual steps (see README.txt) to 
# install MySQL.
#

if [ "$MAVEN_OPTS" = "" ] ; then
  echo "Please set your MAVEN_OPTS per the README"
  exit
fi
if [ "$JAVA_OPTS" = "" ] ; then
  echo "Please set your JAVA_OPTS per the README"
  exit
fi
# Do it all!
# Clean out the repo so any unbuild artifacts will need to be downloaded
rm -rf ~/.m2/repository/org/sakaiproject
# make a fresh copy of Tomcat
sh na.sh
# Check out all of the Sakai source
sh co.sh
# Compile it all, capturing the log
sh qmv.sh | tee /tmp/qmv.out
# Check for Sakai artifacts that were not built
egrep 'Downloading.*\/sakaiproject|====' /tmp/qmv.out | grep -v plugins | sed 's/.*Downloading/Downloading/'
