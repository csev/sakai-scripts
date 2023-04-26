#! /bin/bash

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
if ! [ -x "$(command -v stdbuf)" ]; then
  bash $1 2>> /tmp/shellout >> /tmp/shellout
else
  stdbuf -i0 -o0 -e0 bash $1 2>> /tmp/shellout >> /tmp/shellout
fi

echo ==== Finished $1 at `date` >> /tmp/shellout



