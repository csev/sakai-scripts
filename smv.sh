#! /bin/sh
# Simply echo the proper maven command for hand builds
if [ "$MAVEN_OPTS" = "" ] ; then
  echo "Please set your MAVEN_OPTS per the README"
  exit
fi
if [ "$JAVA_OPTS" = "" ] ; then
  echo "Please set your JAVA_OPTS per the README"
  exit
fi

tomcatver=apache-tomcat-7.0.21

startwd=`pwd`
for i in `seq 1 15`; do
   newwd=`pwd`
   if [ -d $tomcatver ] ; then
     break
   fi
   cd ..
done
if [ -d $tomcatver ] ; then
   tomcatdir=$newwd/$tomcatver
else
   echo "Could not find " $tomcatver " in path"
   echo $startwd
   exit
fi
cd $startwd
echo mvn -Dmaven.tomcat.home=$tomcatdir clean install sakai:deploy
mvn -Dmaven.tomcat.home=$tomcatdir clean install sakai:deploy
