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

TOMCAT_MAJOR=${TOMCAT%%.*}
TOMCATURL=https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v$TOMCAT/bin/apache-tomcat-$TOMCAT.zip
echo $TOMCATURL

if [ -f keepzips/apache-tomcat-$TOMCAT.zip ]
then
  echo keepzips/apache-tomcat-$TOMCAT.zip exists...
else
  echo Downloading keepzips/tomcat-$TOMCAT.zip ...
  cd keepzips
  if ! curl -f -O $TOMCATURL
  then
    echo "======"
    echo "Error, unable to download Tomcat version $TOMCAT"
    echo "Tried $TOMCATURL"
    echo "======"
    cd $MYPATH
    exit 1
  fi
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

if [ -f  patches/apache-$TOMCAT-context.xml ]
then
    cp patches/apache-$TOMCAT-context.xml apache-tomcat-$TOMCAT/conf/context.xml
else
    echo "ERROR: You need a patch for apache-$TOMCAT-context.xml"
    exit
fi

FROMFILE="patches/apache-$TOMCAT-jdk17-setenv.sh"
if [ -f  $FROMFILE ]
then
    cp $FROMFILE apache-tomcat-$TOMCAT/bin/setenv.sh
else
    echo "ERROR: You need a patch for $FROMFILE"
    exit
fi

FROMFILE="patches/apache-$TOMCAT-jdk17-catalina.properties"
if [ -f  $FROMFILE ]
then
    cp $FROMFILE apache-tomcat-$TOMCAT/conf/catalina.properties
else
    echo "ERROR: You need a patch for $FROMFILE"
    exit
fi

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
echo Hibernate dialect: $HIBERNATE_DIALECT
sed < $PROPFILE "s'MYSQL_USER'$MYSQL_USER'" | sed "s'MYSQL_PASSWORD'$MYSQL_PASSWORD'" | sed "s'MYSQL_SOURCE'$MYSQL_SOURCE'" | sed "s'HIBERNATE_DIALECT'$HIBERNATE_DIALECT'" | sed "s'username@javax.sql.BaseDataSource=sakaiuser'username@javax.sql.BaseDataSource=$MYSQL_USER'" | sed "s'password@javax.sql.BaseDataSource=sakaipass'password@javax.sql.BaseDataSource=$MYSQL_PASSWORD'" > apache-tomcat-$TOMCAT/sakai/sakai.properties

if [ -f "server-${TOMCAT_MAJOR}.xml" ]
then
    echo "Using local server-${TOMCAT_MAJOR}.xml"
    cp server-${TOMCAT_MAJOR}.xml apache-tomcat-$TOMCAT/conf/server.xml
elif [ -f "server.xml" ]
then
    echo "Using local server.xml"
    cp server.xml apache-tomcat-$TOMCAT/conf/server.xml
elif [ -f "patches/server-localhost-${TOMCAT_MAJOR}.xml" ]
then
    echo "Using patches/server-localhost-${TOMCAT_MAJOR}.xml"
    sed < patches/server-localhost-${TOMCAT_MAJOR}.xml "s/8080/$PORT/" | sed "s/8005/$SHUTDOWN_PORT/" > apache-tomcat-$TOMCAT/conf/server.xml
else
    echo "Patching stock server.xml"
    sed < apache-tomcat-$TOMCAT/conf/server.xml "s/8080/$PORT/" | sed "s/8005/$SHUTDOWN_PORT/" > apache-tomcat-$TOMCAT/conf/server.xml
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

There are sample server.xml files in patches/, versioned by Tomcat major:

    patches/server-localhost-9.xml / patches/server-localhost-10.xml
    patches/server-internal-https-9.xml / patches/server-internal-https-10.xml  (certbot)
    patches/server-external-https-9.xml / patches/server-external-https-10.xml  (CloudFlare)
    patches/server-self-signed-9.xml / patches/server-self-signed-10.xml

na.sh installs patches/server-localhost-\$TOMCAT_MAJOR.xml by default.
To keep a local override per major so you can switch 9/10, copy a sample to
server-9.xml or server-10.xml. An unversioned server.xml still works for both.

EOF


