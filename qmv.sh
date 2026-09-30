#! /bin/bash
# Compile all of the Sakai source in the right order
#
# A good way to do this is:
#
# rm -rf ~/.m2/repository/org/sakaiproject
# bash qmv.sh | tee /tmp/qmv.out
#
# This way you get a log of what happens and figure out any loose 
# linkage or sloppy dependencies.
#
# Here is a good command to run on the log:
#
# egrep 'Downloading.*\/sakaiproject|====' /tmp/qmv.out | grep -v plugins | sed 's/.*Downloading/Downloading/'
# 
# This will show you which bits of the final compile were downloaded instead of compiled
# You should see none # if we are generating all the binary artifacts from source and things are
# pointing to the right versions.

if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then
    echo "Bad configuration or wrong shell";
    exit
fi

goals='clean install sakai:deploy'
if [ $# != 0 ] ; then
  goals="$@"
fi

mywd=`pwd`
tomcatdir=$mywd/apache-tomcat-$TOMCAT/
echo Compile Sakai from $mywd to $tomcatdir

cd "$mywd/trunk"

mvn_args=(
    -e
    -Dmaven.test.skip=true
    -Dsakai.skip.webcomponents.tests=true
    -Dmaven.tomcat.home="$tomcatdir"
    -Dsakai.cleanup=true
)

if command -v mvnd >/dev/null 2>&1 && [ "${THREADS:-0}" -gt 1 ]; then
    echo mvnd "${mvn_args[@]}" clean install sakai:deploy
    mvnd "${mvn_args[@]}" clean install sakai:deploy

elif [ "${THREADS:-0}" -gt 1 ]; then
    echo "Compiling with $THREADS threads"
    echo mvn -T "$THREADS" "${mvn_args[@]}" $goals
    mvn -T "$THREADS" "${mvn_args[@]}" $goals

else
    echo "Compiling with 1 thread"
    # Given how we register log4j, even -T 1 messes things up
    echo mvn "${mvn_args[@]}" $goals
    mvn "${mvn_args[@]}" $goals
fi

