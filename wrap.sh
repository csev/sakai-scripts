#! /bin/bash

source ~/.bash_profile

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "nohup wrap.sh wraptest.sh > /dev/null 2> /dev/null &"
    echo "tail -f /tmp/shellout"
    echo 
    echo "nohup wrap.sh qmv.sh > /dev/null 2> /dev/null &"
    exit
fi

echo >> /tmp/shellout
echo ==== Starting $1 at `date` >> /tmp/shellout

IFS=';' read -a words <<<"$1"
for word in "${words[@]}"; do

if [[ $word == *sh ]] # * is used for pattern matching
then
  echo "true";
  if ! [ -x "$(command -v stdbuf)" ]; then
    bash $word 2>> /tmp/shellout >> /tmp/shellout
  else
    stdbuf -i0 -o0 -e0 bash $word 2>> /tmp/shellout >> /tmp/shellout
  fi
else
  echo "false"
  $word 2>> /tmp/shellout >> /tmp/shellout
fi

done

echo ==== Finished $1 at `date` >> /tmp/shellout



