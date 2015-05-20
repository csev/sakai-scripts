#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

# If you want to change this file (and you should)
# Simply copy it to config.sh and make your changes
# there so git ignores your local copy.

# Check to see if we are overriden - but only do it once
if [ -f "config.sh" -a "$1" == "" ]
then
    source config.sh include
    return
else
    echo "If you want to override configuration settings, copy"
    echo "config-dist.sh to connfig.sh and edit config.sh"
fi

# Settings
# GIT_REPO=https://github.com/csev/sakai.git
GIT_REPO=https://github.com/sakaiproject/sakai.git
TOMCAT=7.0.21
# Leave LOG_DIRECTORY value empty to leave the logs inside tomcat
# LOG_DIRECTORY=/var/www/html/sakai/logs/tomcat
LOG_DIRECTORY=
PORT=8080
SHUTDOWN_PORT=8005
MYSQL_DATABASE=sakaidb
MYSQL_USER=sakaiuser
MYSQL_PASSWORD=sakaipass
MYSQL_COMMAND='mysql -u root --password=root'
MYSQL_SOURCE="jdbc:mysql://127.0.0.1:3306/$MYSQL_DATABASE?useUnicode=true\&characterEncoding=UTF-8"

# Make a guess if we see MAMP installed
if [ -f "/Applications/MAMP/Library/bin/mysql" ] ; then
    MYSQL_COMMAND='/Applications/MAMP/Library/bin/mysql -S /Applications/MAMP/tmp/mysql/mysql.sock -u root --password=root'
    MYSQL_SOURCE="jdbc:mysql://127.0.0.1:8889/$MYSQL_DATABASE?useUnicode=true\&characterEncoding=UTF-8"
fi

# Do some sanity checking...
if [ "$MAVEN_OPTS" = "" ] ; then
  echo "Unable to continue - Please set your MAVEN_OPTS per the README"
  exit
fi
if [ "$JAVA_OPTS" = "" ] ; then
  echo "Unable to continue - Please set your JAVA_OPTS per the README"
  exit
fi

