Installation
------------

Download the ojdbc14.jar and put it in the folder

    oracle/ojdbc14.jar

Also place this jar in the folder `apache-tomcat.../common/lib`

Install HenPlus from:

    http://sourceforge.net/projects/henplus/files/

Into the folder

    oracle/henplus-0.9.7

Install VirtualBox and then grab the Oracle Developer Day
appliance to get a fully-configured Linux and Oracle bundle.

    http://www.oracle.com/technetwork/database/enterprise-edition/databaseappdev-vm-161299.html


If that URL does not work, google for "oracle developer day virtual box appliance"
It should be the first result.

Of course get the virtual box running.  The login creds are oracle/oracle.

It starts up beautifully - it has a terminal widow with some shell scripts
to reset things.  Much of the work will be done 
in [SQL Developer](oracle/making_connection.png) application or the shell.

Make a Connection in Your Oracle Instance
-----------------------------------------

Open [SQL Developer](oracle/making_connection.png) in your VirtualBox.

Press "+" to make a new connection and enter fields as follows:

    Name: orcl
    Username: SYSTEM
    Password: oracle
    Tick the "Save Password"
    Leace the Hostname and port as localhost 1521
    Change the SID to orcl
    Leave the tick boxes alone.

Once the connrection is created, it is a good idea to check that it 
is accessible from your mac environment 
using [HenPlus](oracle/using-henplus.txt).


Configuring your Sakai Instance
-------------------------------

The file `sakai-dist.properties` has the oracle magic commented out but
we also include it here for reference:

    # VirtualBox - Linux login oracle / oracle
    username@javax.sql.BaseDataSource=SYSTEM
    password@javax.sql.BaseDataSource=oracle
    vendor@org.sakaiproject.db.api.SqlService=oracle
    driverClassName@javax.sql.BaseDataSource=oracle.jdbc.driver.OracleDriver
    hibernate.dialect=org.hibernate.dialect.Oracle10gDialect
    url@javax.sql.BaseDataSource=jdbc:oracle:thin:@localhost:1521:orcl
    validationQuery@javax.sql.BaseDataSource=select 1 from DUAL
    defaultTransactionIsolationString@javax.sql.BaseDataSource=TRANSACTION_READ_COMMITTED

If you want to have oracle set as the default each time you 
run `na.sh` to reset your Tomcat, simply copy `sakai-dist.properties`
to `sakai.properties` and make the changes you like to `sakai.properties`.
Then `na.sh` will take your `sakai.properties` as the default when it
makes a new Tomcat.

Of course install the correct `sakai.properties` in `apache-tomcat...\sakai`
before starting Sakai.

While running Sakai, you can use Oracle SQL Developer or 
[HenPlus](oracle/using-henplus.txt) to run queries on your Oracle database.

Old stuff
---------

SELECT 'DROP TABLE "' || table_name || '" CASCADE CONSTRAINTS;' FROM user_tables;

select instance_name from v$instance;
xe

Turn off firewall on windows

connect jdbc:oracle:thin:@192.168.0.134:1521:xe

select * from user_objects where object_type = 'TABLE'; 

Data types notes
----------------

http://technology-ameyaaloni.blogspot.com/2010/06/mysql-to-hsql-migration-tips.html

http://borkweb.com/story/oracles-auto-incrementing-with-sequences

http://ss64.com/ora/syntax-datatypes.html


[1](http://www.jochenhebbrecht.be/site/2010-05-10/database/drop-all-tables-in-oracle-db-scheme)
