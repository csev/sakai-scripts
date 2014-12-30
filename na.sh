#! /bin/sh
source config-dist.sh

MYPATH=`pwd`

echo Setting up fresh TOMCAT Version:$TOMCAT 

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

echo Copying needed jars to common/lib
cp jars/*.jar apache-tomcat-$TOMCAT/common/lib

mkdir -p apache-tomcat-$TOMCAT/sakai

echo Patching sakai.properties
PROPFILE="sakai-dist.properties"
if [ -f "sakai.properties" ]
then
    echo "Using local sakai.properties"
    PROPFILE="sakai.properties"
fi

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
