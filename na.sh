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

# http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.30/bin/apache-tomcat-8.0.30.zip
echo http://archive.apache.org/dist/tomcat/tomcat-8/v$TOMCAT/bin/apache-tomcat-$TOMCAT.zip

if [ -f keepzips/apache-tomcat-$TOMCAT.zip ] 
then
  echo keepzips/apache-tomcat-$TOMCAT.zip exists...
else 
  echo Downloading keepzips/tomcat-$TOMCAT.zip ...
  cd keepzips
  # curl -O http://apache.arvixe.com/tomcat/tomcat-8/v$TOMCAT/bin/apache-tomcat-$TOMCAT.zip
  curl -O http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT:0:1}/v$TOMCAT/bin/apache-tomcat-$TOMCAT.zip
  cd $MYPATH
fi

# Get ourselves a MySQL connector jar
if [ -f keepzips/mysql-connector-java-$MYSQL.jar ] 
then
  echo keepzips/mysql-connector-java-$MYSQL.jar exists...
else 
  echo Downloading keepzips/mysql-connector-java-$MYSQL.jar ...
  cd keepzips
  curl -O http://repo.maven.apache.org/maven2/mysql/mysql-connector-java/5.1.35/mysql-connector-java-5.1.35.jar
  ls -l mysql*
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
echo 'export CATALINA_OPTS="-Dsakai.demo=true"' > apache-tomcat-$TOMCAT/bin/setenv.sh

chmod +x apache-tomcat-$TOMCAT/bin/*.sh

# Not needed after 22-Sep-2105
# patch -p0 < patches/tomcat-$TOMCAT.patch
cp patches/apache-$TOMCAT-context.xml apache-tomcat-$TOMCAT/conf/context.xml

echo Setting up webapps/ROOT
rm apache-tomcat-$TOMCAT/webapps/ROOT/*
cp patches/index.html apache-tomcat-$TOMCAT/webapps/ROOT

mkdir -p apache-tomcat-$TOMCAT/lib

# Copy the mysql connector jar into common/lib
cp keepzips/*.jar apache-tomcat-$TOMCAT/lib

# Find an OJDBC Connector jar in oracle folder if we can
OJ=`ls oracle/*ojdbc*jar 2>/dev/null | head -1`
if [ -f "$OJ" ]
then
   echo "Found oracle jar $OJ"
   cp $OJ apache-tomcat-$TOMCAT/common/lib
fi

mkdir -p apache-tomcat-$TOMCAT/sakai

echo Patching sakai.properties
PROPFILE="sakai-dist.properties"
if [ -f "sakai.properties" ]
then
    echo "Using local sakai.properties"
    PROPFILE="sakai.properties"
fi

echo $MYSQL_SOURCE
echo $PROPFILE
sed < $PROPFILE "s'MYSQL_USER'$MYSQL_USER'" | sed "s'MYSQL_PASSWORD'$MYSQL_PASSWORD'" | sed "s'MYSQL_SOURCE'$MYSQL_SOURCE'"> apache-tomcat-$TOMCAT/sakai/sakai.properties

echo "Patching server.xml"

cp apache-tomcat-$TOMCAT/conf/server.xml patches/server.xml
sed < patches/server.xml "s/8080/$PORT/" | sed "s/8005/$SHUTDOWN_PORT/" > apache-tomcat-$TOMCAT/conf/server.xml

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

echo 
echo Make sure to include this when running your Tomcat
echo
echo -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false
echo
