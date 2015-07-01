Installation
------------

Install HenPlus from:

    http://sourceforge.net/projects/henplus/files/

Into the folder

    oracle/henplus-0.9.7

Download the ojdbc6.jar and put it in the folders:

    oracle/
    oracle/henplus-0.9.7/lib/

Also place this jar in the folder `apache-tomcat.../common/lib`

Install VirtualBox and then grab the Oracle Developer Day
appliance to get a fully-configured Linux and Oracle bundle.

    http://www.oracle.com/technetwork/database/enterprise-edition/databaseappdev-vm-161299.html


If that URL does not work, google for "oracle developer day virtual box appliance"
It should be the first result.

Once you download the OVA file.  Keep it - we will need to wipe out the virtualbox
and reinstall it from time to time and it is nice to avoid a multi-hour download.

When you start the virtualbox, the login creds are oracle/oracle.

It starts up beautifully - it has a terminal widow with some shell scripts
to reset things.  Much of the work will be done 
in [SQL Developer](oracle/making_connection.png) application or the shell.

Once the connection is created, it is a good idea to check that it 
is accessible from your mac environment 
using [HenPlus](oracle/using-henplus.txt).


Configuring your Sakai Instance
-------------------------------

The file `sakai-dist.properties` has the Oracle magic commented out but
we also include it here for reference:

    # VirtualBox - Linux login oracle / oracle
    username@javax.sql.BaseDataSource=SYSTEM
    password@javax.sql.BaseDataSource=oracle
    vendor@org.sakaiproject.db.api.SqlService=oracle
    driverClassName@javax.sql.BaseDataSource=oracle.jdbc.driver.OracleDriver
    hibernate.dialect=org.hibernate.dialect.Oracle10gDialect
    url@javax.sql.BaseDataSource=jdbc:oracle:thin:@localhost:1521:cdb1
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

Resetting the Oracle Tables and Sequences
-----------------------------------------

The simple way is to just blast your virtual box and reinstall from the OVA.
But sometimes you want to drop all the tables in your Oracle instance.  Don't
try to drop the `cdb1` database (a.k.a. SID) or you will end up starting
from scratch unless you are an Oracle whiz.  So do this:

    cd oracle
    ./henplus-0.9.7/bin/henplus
    Hen*Plus> connect jdbc:oracle:thin:@localhost:1521:cdb1
    Username: SYSTEM
    Password: oracle
    SYSTEM@oracle:localhost> load DROP.sql

Now you might not get them all if new tables were created since those
lists were created.  Here are two queries to run to see what ones
you might have missed:

    SELECT 'DROP TABLE "' || table_name || '" CASCADE CONSTRAINTS;' FROM user_tables WHERE table_name not like '%$%';
    SELECT 'DROP SEQUENCE "' || sequence_name || '";' FROM user_sequences WHERE sequence_name not like '%$%';
    SELECT 'DROP INDEX "' || index_name || '";' FROM user_indexes WHERE index_name not like '%$%' AND index_name not like 'SYS_%';

If all is well, you should get no rows from those queries, if you get rows,
drop the tables and sequences - and send me a Pull Request to update my
SQL scripts with the new tables.

Data Types Notes
----------------

http://technology-ameyaaloni.blogspot.com/2010/06/mysql-to-hsql-migration-tips.html

http://borkweb.com/story/oracles-auto-incrementing-with-sequences

http://ss64.com/ora/syntax-datatypes.html

References 
----------

[1](http://www.jochenhebbrecht.be/site/2010-05-10/database/drop-all-tables-in-oracle-db-scheme)
