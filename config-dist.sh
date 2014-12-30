# If you want to change this file (and you should)
# Simply copy it to config.sh and make your changes
# there so git ignores your local copy.
if [ -f "config.sh" ]
then
    source config.sh
    exit
fi

# Settings
GIT_REPO=https://github.com/csev/sakai.git
MYSQL_DATABASE=nightly
MYSQL_USER=sakaiuser
MYSQL_PASSWORD=sakaipass
MYSQL_COMMAND='/Applications/MAMP/Library/bin/mysql -S /Applications/MAMP/tmp/mysql/mysql.sock -u root --password=root'
MYSQL_SOURCE='jdbc:mysql://127.0.0.1:8889/sakai?useUnicode=true&characterEncoding=UTF-8'


# Do some sanity checking...
if [ "$MAVEN_OPTS" = "" ] ; then
  echo "Unable to continue - Please set your MAVEN_OPTS per the README"
  exit
fi
if [ "$JAVA_OPTS" = "" ] ; then
  echo "Unable to continue - Please set your JAVA_OPTS per the README"
  exit
fi

