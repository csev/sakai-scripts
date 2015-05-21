#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then 
    echo "Bad configuration or wrong shell"; 
    exit 
fi

MYPATH=`pwd`

# Find a JDBC Connector jar or die trying...
JAR=""
JJ=`ls jars/*jar | head -1`
MJ=`ls ../*/*mysql-connector-java*jar | head -1`
OJ=`ls ../*/*ojdbc*jar | head -1`
if [ -f "$JJ" ]
then
    echo "Found local jars"
    JAR='jars/*jar'
elif [ -f "/usr/share/java/mysql.jar" ]
then
   echo "Found linux mysql jar from apt-get install"
   JAR="/usr/share/java/mysql.jar"
elif [ -f "$MJ" ]
then
   echo "Found mysql jar $MJ"
   JAR=$MJ
elif [ -f "$OJ" ]
then
   echo "Found oracle jar $OJ"
   JAR=$OJ
else
   echo "Missing /usr/share/java/mysql.jar"
   echo "Please run"
   echo " "
   echo "sudo apt-get install libmysql-java"
   exit
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

if [ -f keepzips/tomcat-$TOMCAT.zip ] 
then
  echo keepzips/tomcat-$TOMCAT.zip exists...
else 
  echo Downloading keepzips/tomcat-$TOMCAT.zip ...
  cd keepzips
  curl -O http://source.sakaiproject.org/maven2/tomcat/tomcat/tomcat/$TOMCAT/tomcat-$TOMCAT.zip
  cd $MYPATH
fi

rm -rf apache-tomcat-$TOMCAT/

echo Extracting Tomcat...
unzip -q keepzips/tomcat-$TOMCAT.zip

chmod +x apache-tomcat-$TOMCAT/bin/*.sh

patch -p0 < patches/tomcat-7.0.21.patch

mkdir -p apache-tomcat-$TOMCAT/common/classes
mkdir -p apache-tomcat-$TOMCAT/server/classes
mkdir -p apache-tomcat-$TOMCAT/shared/classes
mkdir -p apache-tomcat-$TOMCAT/server/lib
mkdir -p apache-tomcat-$TOMCAT/common/lib

cp $JAR apache-tomcat-$TOMCAT/common/lib

mkdir -p apache-tomcat-$TOMCAT/sakai

echo Patching sakai.properties
PROPFILE="sakai-dist.properties"
if [ -f "sakai.properties" ]
then
    echo "Using local sakai.properties"
    PROPFILE="sakai.properties"
fi

echo "KJSKKSAJ" $MYSQL_SOURCE
echo $PROPFILE
sed < $PROPFILE "s'MYSQL_USER'$MYSQL_USER'" | sed "s'MYSQL_PASSWORD'$MYSQL_PASSWORD'" | sed "s'MYSQL_SOURCE'$MYSQL_SOURCE'"> apache-tomcat-$TOMCAT/sakai/sakai.properties

echo "Patching server.xml"

sed < patches/server.xml "s/8080/$PORT/" | sed "s/8005/$SHUTDOWN_PORT/" > apache-tomcat-$TOMCAT/conf/server.xml

if [ "$LOG_DIRECTORY" != "" ]; then 
    echo "Logging to " $LOG_DIRECTORY
    sed < patches/logging.properties "s'\${catalina.base}/logs'$LOG_DIRECTORY'g" > apache-tomcat-$TOMCAT/conf/logging.properties    
    echo "Setting up setenv.sh"
cat > apache-tomcat-$TOMCAT/bin/setenv.sh << EOF
CATALINA_OUT=$LOG_DIRECTORY/catalina.out
EOF

fi

echo 
echo Make sure to include this when running your Tomcat
echo
echo -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false
echo
