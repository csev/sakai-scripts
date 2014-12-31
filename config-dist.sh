#! /bin/bash

# If you want to change this file (and you should)
# Simply copy it to config.sh and make your changes
# there so git ignores your local copy.
if [ -f "config.sh" -a "$1" == "" ]
then
    source config.sh include
    return
fi

# Settings
GIT_REPO=https://github.com/csev/sakai.git
TOMCAT=7.0.21
MYSQL_DATABASE=nightly
MYSQL_USER=sakaiuser
MYSQL_PASSWORD=sakaipass
MYSQL_COMMAND='/Applications/MAMP/Library/bin/mysql -S /Applications/MAMP/tmp/mysql/mysql.sock -u root --password=root'
# Change the database name below as well - also escape the ampersand
MYSQL_SOURCE='jdbc:mysql://127.0.0.1:8889/nightly?useUnicode=true\&characterEncoding=UTF-8'

# Leave this empty to leave the logs alone
LOG_DIRECTORY=/tmp/logs
PORT=8080
SHUTDOWN_PORT=8005

# Do some sanity checking...
if [ "$MAVEN_OPTS" = "" ] ; then
  echo "Unable to continue - Please set your MAVEN_OPTS per the README"
  exit
fi
if [ "$JAVA_OPTS" = "" ] ; then
  echo "Unable to continue - Please set your JAVA_OPTS per the README"
  exit
fi

