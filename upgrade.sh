#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

# Do some sanity checking...
if [ "$JAVA_OPTS" != "" ] ; then
  grep -q 'ALL-UNNAMED' << EOF
$JAVA_OPTS
EOF
  greprc=$?
  if [[ $greprc -eq 1 ]] ; then 
    echo "======"
    echo "You do not have a Java 11 version of your JAVA_OPTS"
    echo "Please update your JAVA_OPTS per the profile.txt file."
    echo "======"
  fi
fi

