#! /bin/bash

# This file should be copied into a folder in the PATH
# so it can be used to compile from any point in the Sakai
# hierarchy that has a pom.xml

if [ "$MAVEN_OPTS" = "" ] ; then
  echo "Please set your MAVEN_OPTS per the README"
  exit
fi
if [ "$JAVA_OPTS" = "" ] ; then
  echo "Please set your JAVA_OPTS per the README"
  exit
fi

startwd=`pwd`
for i in `seq 1 15`; do
   newwd=`pwd`
   if [ -d keepzips ] ; then
     break
   fi
   cd ..
done
if [ -d keepzips ] ; then
   tomcatdir=$newwd/`ls -d apache-tomcat* | tail -1`
else
   echo "Could not find " $tomcatver " in path"
   echo $startwd
   exit
fi
cd $startwd

export MAVEN_OPTS='-Xms512m -Xmx1024m -Djava.util.Arrays.useLegacyMergeSort=true'

echo "Running this maven command:"
echo " "
echo mvn -Dmaven.tomcat.home=$tomcatdir clean install sakai:deploy

mvn -Dmaven.tomcat.home=$tomcatdir clean install sakai:deploy
