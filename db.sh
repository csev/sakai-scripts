#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then
    echo "Bad configuration or wrong shell";
    exit
fi

if [[ ! -v $LOCAL_HOST_ACCESS ]]; then $LOCAL_HOST_ACCESS=localhost; fi

echo === Checking MariaDB/MySql configuration ===

rm -f /tmp/mysql

echo $MYSQL_COMMAND

$MYSQL_COMMAND << EOF > /tmp/mysql
SHOW DATABASES;
EOF

if grep information_schema /tmp/mysql > /dev/null
then
    echo "MariaDB/MySQL service is working..."
else
    echo "MariaDB/MySQL is not installed or not configured correctly"
    echo ""
    echo $MYSQL_COMMAND
    echo "SHOW DATABASES;"
    echo " "
    cat /tmp/mysql
    exit 1
fi

echo === Creating $MYSQL_DATABASE database

$MYSQL_COMMAND << EOF
DROP DATABASE IF EXISTS $MYSQL_DATABASE;

CREATE DATABASE $MYSQL_DATABASE DEFAULT CHARACTER SET UTF8;

CREATE USER IF NOT EXISTS '$MYSQL_USER'@'$LOCAL_HOST_ACCESS' IDENTIFIED BY '$MYSQL_PASSWORD';
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'127.0.0.1' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL ON $MYSQL_DATABASE.* TO $MYSQL_USER@'$LOCAL_HOST_ACCESS';
GRANT ALL ON $MYSQL_DATABASE.* TO $MYSQL_USER@'127.0.0.1';
ALTER USER $MYSQL_USER@'$LOCAL_HOST_ACCESS' IDENTIFIED BY '$MYSQL_PASSWORD';
ALTER USER $MYSQL_USER@'127.0.0.1' IDENTIFIED BY '$MYSQL_PASSWORD';
EOF

echo " "
echo "Active MariaDB/MySQL Databases:"

$MYSQL_COMMAND << EOF
SHOW DATABASES;
EOF

echo " "
echo "You will need add / update these lines in your sakai.properties"
echo " "
echo username@javax.sql.BaseDataSource=$MYSQL_USER
echo password@javax.sql.BaseDataSource=$MYSQL_PASSWORD
echo url@javax.sql.BaseDataSource=$MYSQL_SOURCE


