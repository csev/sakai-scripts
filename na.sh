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
if [ -f "$OJ" ]
then
   echo "Found oracle jar $OJ"
   JAR=$OJ
elif [ -f "/usr/share/java/mysql.jar" ]
then
   echo "Found linux mysql jar from apt-get install"
   JAR="/usr/share/java/mysql.jar"
elif [ -f "$MJ" ]
then
   echo "Found mysql jar $MJ"
   JAR=$MJ
elif [ -f "$JJ" ]
then
    echo "Found local jars"
    JAR='jars/*jar'
else
   echo "Downloading MySQL jar from maven"
   cd jars
   curl -O http://repo.maven.apache.org/maven2/mysql/mysql-connector-java/5.1.35/mysql-connector-java-5.1.35.jar
   cd ..
   JJ=`ls jars/*jar | head -1`
   if [ -f "$JJ" ]
   then
      echo "Found local jars"
      JAR='jars/*jar'
   else
      echo "Missing /usr/share/java/mysql.jar"
      echo "Please manually download the mysql connector and put"
      echo "it in the jard folder"
      exit
   fi
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

if [ -f keepzips/apache-tomcat-$TOMCAT.zip ] 
then
  echo keepzips/apache-tomcat-$TOMCAT.zip exists...
else 
  echo Downloading keepzips/tomcat-$TOMCAT.zip ...
  cd keepzips
  curl -O http://psg.mtu.edu/pub/apache/tomcat/tomcat-8/v$TOMCAT/bin/apache-tomcat-$TOMCAT.zip
  cd $MYPATH
fi

rm -rf apache-tomcat-$TOMCAT/

echo Extracting Tomcat...
unzip -q keepzips/apache-tomcat-$TOMCAT.zip

chmod +x apache-tomcat-$TOMCAT/bin/*.sh

patch -p0 < patches/tomcat-$TOMCAT.patch
cp patches/apache-$TOMCAT-context.xml apache-tomcat-$TOMCAT/conf/context.xml

mkdir -p apache-tomcat-$TOMCAT/common/classes
mkdir -p apache-tomcat-$TOMCAT/server/classes
mkdir -p apache-tomcat-$TOMCAT/shared/classes
mkdir -p apache-tomcat-$TOMCAT/shared/lib
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
