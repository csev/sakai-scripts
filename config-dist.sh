#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

# If you want to change this file (and you should)
# Simply copy it to config.sh and make your changes
# there so git ignores your local copy.

# Check to see if we are overriden - but only do it once
if [ -f "config.sh" -a "$1" == "" ]
then
    echo "Taking configuration from local config.sh"
    source upgrade.sh include
    source config.sh include
    return
    exit
elif [ "$1" == "" ]
then
    echo "Using defaults from config-dist.php."
    echo "If you want to override configuration settings, copy"
    echo "config-dist.sh to config.sh and edit config.sh"
fi

# Settings start here
# Number of mvn threads
THREADS=2

# Change GIT_REPO and replace "sakaiproject" with your git user name
# so that you checkout your forked sakai repository
GIT_REPO=https://github.com/sakaiproject/sakai.git

# Set this to the MYSQL root passsword.  MAMP's default
# is root so you can leave it alone if you are using MAMP
MYSQL_ROOT_PASSWORD=root

MYSQL=5.1.35
TOMCAT=8.0.30

# Leave LOG_DIRECTORY value empty to leave the logs inside tomcat
# LOG_DIRECTORY=/var/www/html/sakai/logs/tomcat
LOG_DIRECTORY=
PORT=8080
SHUTDOWN_PORT=8005
MYSQL_DATABASE=sakai11
MYSQL_USER=sakaiuser
MYSQL_PASSWORD=sakaipass

# Defaults for Mac/MAMP MySQL
if [ -f "/Applications/MAMP/Library/bin/mysql" ] ; then
    MYSQL_SOURCE="jdbc:mysql://127.0.0.1:8889/$MYSQL_DATABASE?useUnicode=true\&characterEncoding=UTF-8"
    MYSQL_COMMAND="/Applications/MAMP/Library/bin/mysql -S /Applications/MAMP/tmp/mysql/mysql.sock -u root --password=$MYSQL_ROOT_PASSWORD"

# Ubuntu / normal 3306 MySQL 
else
    MYSQL_COMMAND="mysql -u root --host=127.0.0.1 --password=$MYSQL_ROOT_PASSWORD"
    MYSQL_SOURCE="jdbc:mysql://127.0.0.1:3306/$MYSQL_DATABASE?useUnicode=true\&characterEncoding=UTF-8"
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

