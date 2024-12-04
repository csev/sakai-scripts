#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then 
    echo "Bad configuration or wrong shell"; 
    exit 
fi

MYPATH=`pwd`

if [ "$MYSQL" = "" ]
then
MYSQL=5.1.35
   echo "Assuming MySQL Version $MYSQL"
fi

echo Setting up fresh TOMCAT Version:$TOMCAT 
echo Using JAR: $JAR

source stop.sh

# Download Tomcat using curl if necessary

if [ -d keepzips ] 
then
  echo keepzips directory exists...
else
  echo Creating keepzips directory ...
  mkdir keepzips
fi

TOMCATURL=https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT:0:1}/v$TOMCAT/bin/apache-tomcat-$TOMCAT.zip
echo $TOMCATURL

if [ -f keepzips/apache-tomcat-$TOMCAT.zip ] 
then
  echo keepzips/apache-tomcat-$TOMCAT.zip exists...
else 
  echo Downloading keepzips/tomcat-$TOMCAT.zip ...
  cd keepzips
  curl -O $TOMCATURL
  cd $MYPATH
fi

rm -rf apache-tomcat-$TOMCAT/

echo Extracting Tomcat...
unzip -q keepzips/apache-tomcat-$TOMCAT.zip

if [ ! -d apache-tomcat-$TOMCAT ] ; then
  echo "======"
  echo "Error, unable to download Tomcat version $TOMCAT"
  echo "You may need to switch to another version in your configuration"
  echo "or another server n the na.sh script"
  echo "======"
  rm keepzips/*
  exit
fi

# Demo setup
echo 'export CATALINA_OPTS="-Dsakai.demo=false"' > apache-tomcat-$TOMCAT/bin/setenv.sh

chmod +x apache-tomcat-$TOMCAT/bin/*.sh

# Not needed after 22-Sep-2105
# patch -p0 < patches/tomcat-$TOMCAT.patch
cp patches/apache-$TOMCAT-context.xml apache-tomcat-$TOMCAT/conf/context.xml

echo Setting up webapps/ROOT
rm -r apache-tomcat-$TOMCAT/webapps/ROOT/*
cp patches/index.html apache-tomcat-$TOMCAT/webapps/ROOT
cp patches/favicon.ico apache-tomcat-$TOMCAT/webapps/ROOT

mkdir -p apache-tomcat-$TOMCAT/lib

# Find an OJDBC Connector jar in oracle folder if we can
OJ=`ls oracle/*ojdbc*jar 2>/dev/null | head -1`
if [ -f "$OJ" ]
then
   echo "Found oracle jar $OJ"
   cp $OJ apache-tomcat-$TOMCAT/common/lib
else
   # Copy the connector jars into common/lib
   # For example: keepzips/mariadb-java-client-2.7.3.jar
   echo keepzips/*.jar
   cp keepzips/*.jar apache-tomcat-$TOMCAT/lib
fi

if ls -d *.jks 1>/dev/null 2>/dev/null; then
    echo Copied keystores into apache-tomcat-$TOMCAT/conf: *.jks
    cp *.jks apache-tomcat-$TOMCAT/conf
fi

mkdir -p apache-tomcat-$TOMCAT/sakai

PROPFILE="sakai-dist.properties"
if [ -f "sakai.properties" ]
then
    echo "Using local sakai.properties"
    PROPFILE="sakai.properties"
else
    echo
    echo Using $PROPFILE for sakai.properties
    echo You can create your own sakai.properties if you want
    echo You could start by making a copy of the default properties
    echo
    echo cp $PROPFILE sakai.properties
    echo
    echo and edit that file to customize it
    echo
fi

echo Cleaning up folders from the Tomcat distro

rm -r apache-tomcat-$TOMCAT/webapps/docs/ apache-tomcat-$TOMCAT/webapps/examples/ apache-tomcat-$TOMCAT/webapps/host-manager/ apache-tomcat-$TOMCAT/webapps/manager/

echo Patching sakai.properties with SQL access information if needed


echo $MYSQL_SOURCE
echo $PROPFILE
sed < $PROPFILE "s'MYSQL_USER'$MYSQL_USER'" | sed "s'MYSQL_PASSWORD'$MYSQL_PASSWORD'" | sed "s'MYSQL_SOURCE'$MYSQL_SOURCE'" | sed "s'username@javax.sql.BaseDataSource=sakaiuser'username@javax.sql.BaseDataSource=$MYSQL_USER'" | sed "s'password@javax.sql.BaseDataSource=sakaipass'password@javax.sql.BaseDataSource=$MYSQL_PASSWORD'" > apache-tomcat-$TOMCAT/sakai/sakai.properties

if [ -f "server.xml" ]
then
    echo "Using local server.xml"
    cp server.xml apache-tomcat-$TOMCAT/conf/server.xml
else
    echo "Patching server.xml"
    cp apache-tomcat-$TOMCAT/conf/server.xml patches/server.xml
    sed < patches/server.xml "s/8080/$PORT/" | sed "s/8005/$SHUTDOWN_PORT/" > apache-tomcat-$TOMCAT/conf/server.xml
fi

if [ "$LOG_DIRECTORY" != "" ]; then 
    echo "Logging to " $LOG_DIRECTORY
    cp apache-tomcat-$TOMCAT/conf/logging.properties patches/logging.properties
    sed < patches/logging.properties "s'\${catalina.base}/logs'$LOG_DIRECTORY'g" > apache-tomcat-$TOMCAT/conf/logging.properties    
    echo "Setting up setenv.sh"
cat > apache-tomcat-$TOMCAT/bin/setenv.sh << EOF
apache-tomcat-$TOMCAT
CATALINA_OUT=$LOG_DIRECTORY/catalina.out
EOF
fi


echo "Setting up root redirect to /portal in apache-tomcat-$TOMCAT/conf/Catalina/localhost"
echo
mkdir apache-tomcat-$TOMCAT/conf/Catalina
mkdir apache-tomcat-$TOMCAT/conf/Catalina/localhost
cp patches/rewrite.config apache-tomcat-$TOMCAT/conf/Catalina/localhost/rewrite.config

echo Rewrite rules in apache-tomcat-$TOMCAT/conf/Catalina/localhost/rewrite.config
echo
cat apache-tomcat-$TOMCAT/conf/Catalina/localhost/rewrite.config
echo
echo "If your Host entry in server.xml is different than localhost you might need some manual configuration"
echo


cat << EOF
If you are running this Tomcat behind a load balancer or proxy, make sure
to have the correct port and add the "secure" and "scheme" options
in apache-tomcat-$TOMCAT/conf/server.xml

    <Connector port="$PORT" protocol="HTTP/1.1"
               connectionTimeout="20000"
               secure="true"
               scheme="https"
               redirectPort="8443" />

There are several sample server.xml files for various scenarios:

    server-localhost.xml
    server-internal-https.xml  (i.e. using certbot)
    server-external-https.xml  (i.e. like CloudFlare)

You can copy one of these to server.xml so that it is always installed into
your fresh Tomcat.

EOF


