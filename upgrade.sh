#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

# Do some sanity checking...
if [ "$JAVA_OPTS" != "" ] ; then
  grep -q 'XX:MaxMetaspaceSize=512m' << EOF
$JAVA_OPTS
EOF
  greprc=$?
  if [[ $greprc -eq 1 ]] ; then 
    echo "======"
    echo "You do not have -XX:MaxMetaspaceSize=512m in your JAVA_OPTS"
    echo "Please update your JAVA_OPTS per the profile.txt file."
    echo "======"
  fi
fi

