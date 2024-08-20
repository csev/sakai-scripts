#! /bin/bash

# This file should be copied into a folder in the PATH
# so it can be used to compile from any point in the Sakai
# hierarchy that has a pom.xml

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


if [ -e "pom.xml" ]; then
    x=`sed -n 's:.*<packaging>\(.*\)</packaging>.*:\1:p' pom.xml`
    if [ "$x" = "war" ]; then
        packaging="This folder builds a war file, you should not have to restart your Tomcat"
    elif [ "$x" = "jar" ]; then
        packaging="This folder builds a jar file, you probably will need to restart your Tomcat"
    elif [ "$x" = "sakai-component" ]; then
        packaging="This folder builds a Sakai service, it requires a restart of your Tomcat"
    else
        packaging="You probably need to restart your Tomcat after building this folder"
    fi
else
    packaging="You probably need to restart your Tomcat after building this folder"
fi

export MAVEN_OPTS='-Xms512m -Xmx1024m -Djava.util.Arrays.useLegacyMergeSort=true'

echo "Running these commands:"
echo " "
echo export MAVEN_OPTS='-Xms512m -Xmx1024m -Djava.util.Arrays.useLegacyMergeSort=true'
echo " "
echo mvn -Dmaven.tomcat.home=$tomcatdir clean install sakai:deploy
echo " "
echo "or "
echo " "
echo mvn -Dmaven.tomcat.home=$tomcatdir -Dmaven.test.skip=true clean install sakai:deploy
echo " "
echo $packaging
echo

mvn -Dmaven.tomcat.home=$tomcatdir clean install sakai:deploy

echo " "
echo $packaging
echo
