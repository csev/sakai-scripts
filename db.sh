#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then 
    echo "Bad configuration or wrong shell"; 
    exit 
fi

echo === Creating $MYSQL_DATABASE database

$MYSQL_COMMAND << EOF
DROP DATABASE IF EXISTS $MYSQL_DATABASE;

CREATE DATABASE $MYSQL_DATABASE DEFAULT CHARACTER SET UTF8;

GRANT ALL ON $MYSQL_DATABASE.* TO $MYSQL_USER@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL ON $MYSQL_DATABASE.* TO $MYSQL_USER@'127.0.0.1' IDENTIFIED BY '$MYSQL_PASSWORD';
EOF

echo " "
echo You might want to use the mysql command line to make sure your
echo $MYSQL_DATABASE was created properly
