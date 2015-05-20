Sakai-Scripts
=============

Some scripts that I use to make my life as a Sakai developer easier.

This is a set of scripts to set up a developer instance of Sakai on 
your system or set up a nighly build.  Sakai can run on a 2GB RAM system
but is a lot more comfortable with a 4GB or more app server.

Make sure to add this to your .bashrc (Linux) or 
.bashrc\_profile (Mac) so your mavens and Sakai can run 
(remove newlines so the JAVA\_OPTS is all on one line):

    JAVA_OPTS='-server -Xms512m -Xmx1024m  
    -XX:NewSize=192m -XX:MaxNewSize=384m -Djava.awt.headless=true -Dhttp.agent=Sakai 
    -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false 
    -Dsun.lang.ClassLoader.allowArraySyntax=true'

    export JAVA_OPTS

    MAVEN_OPTS='-Xms512m -Xmx1024m -XX:PermSize=128m -XX:MaxPermSize=512m'

    export MAVEN_OPTS

Developer Quickstart
====================

This is a quick series of steps to get up and running on a Macintosh:

* Check out this directory
* Make sure that prerequisite software is installed (see ubuntu.sh)
* Either install MAMP (Mac) or have MySql on 3306
* Copy config-dist.sh to config.sh
* Edit config.sh to put in the correct repository
* If you are not running MAMP, edit the MySql root password in config.sh
* Run bash db.sh to create a database
* Run bash na.sh to set up the Tomcat
* Run bash co.sh to check things out
* Run bash qmv.sh to compile it all
* Run bash start.sh to start the Tomcat
* Run bash tail.sh to watch the logs (Press CTRL-C to stop the tail)
* Run bash stop.sh to shutdown Tomcat

* Copy smv.sh into a folder in your PATH so you can recompile any
folder in Sakai that has a pom.xml by typing "smv.sh"

Eventually you can just use the tomcat startup.sh and shutdown.sh
and run your own tail commands if that is what you like.

Description of the Scripts
==========================

Here are the scripts to be run in roughly the following order:

ubuntu.sh
---------

This runs a bunch of apt-get commands to load the pre-requisites for Sakai
for Ubuntu.  If you are running something other than Ubuntu, you can look 
at this and use whatever package manager that is on the system to 
install the necessary pre-requisites.

TODO: OS/X pre-requisite instructions.

config-dist.sh
--------------

This is a configuration script that sets a few parameters.  If you want/
need to tweak the parameters simply copy this to config.sh so git does
not try to check it in.  If there is a config.sh, it will be used instead
of config-dist.sh.   

I think that the default config-dist.sh works without modification for 
normal development Mac OS/X with MAMP installed and running.  For 
normal development on a Linux/Mysql box, probably the only thing you 
would need to change in a config.sh is the root mysql password so it
can set up the database in db.sh

But there is a lot of flexibility here if you are setting up nightly build
servers.   Changing things like the HTTP port, shutdown port, location 
of the Tomcat logs in config.sh allows you check these scripts out 
into several directories and make different nightly builds.  If you get
really tricky, you can override sakai-dist.properties by copying it to 
sakai.properties (which git will ignore) and change lots of things like
switching from MySql to Oracle.  Also you could put the ojdbc jar file
in the jars folder so the db.sh copies that into common/lib each time 
you make a new Apache.  Note that db.sh does not understand oracle so 
your might want to change MYSQL\_COMMAND to be "cat" so it does not try
to run mysql to create an Oracle database.

db.sh
-----
This sets up a MySql database with an account and password based on 
the configuration

co.sh
-----

Checkout all of the Sakai source into the folder trunk.   This checks out
the main Sakai source and a few projects that Sakai depends on in case you
want to peruse the source of those projects.

db.sh
-----
Drop the database if it is there and re-greate an empty database.

na.sh
-----

Download and create a fresh instance of Tomcat, patch configurations, 
and set up a sakai.properties

Since we cannot include the MySQL connector, download a copy of the 
MySQL JDBC connector from:

    http://dev.mysql.com/downloads/connector/j/

Once you download and unzip the connector copy the jar into the
jars folder - it will be copied automatically by na.sh

    mysql-connector-java-5.1.6-bin.jar

Some clever people get their copy of the JDBC connector jar and put it up
on an obscure URL so they can quickly curl it to a new server and put
it in the jars folder.

If you are setting up Oracle you can put the ojdbc jar in the jar folder
so that it is automatically copied.

qmv.sh
------

Compile all of the Sakai source bypassing unit tests.   This saves a lot
of time in the initial compile.   The mv.sh will compile with unit test.
Once things work and you need to go out for an errand, you can run a mv.sh 
to compile with all unit tests.

start.sh
--------
Start tomcat.  Actually this script calls stop.sh at the begining to 
shut down any running tomcat on the configured port so it can aso be 
used as a "restart" to bounce Tomcat.

stop.sh
-------
Stop tomcat

tail.sh
-------
Tail the tomcat log.

Using Sakai
===========

And at this point, you should be able to navigate a browser to:

    http://localhost:8080/portal

If you need to recompile, the steps to shut down Sakai are to first
abort your tail command with a CTRL-C and then run stop.sh

Usually to keep things clean, I remove all the files in the Tomcat logs
folder before I restart Sakai.

Developer Compiles
==================

smv.sh
------

This is for developers working on one or more of the elements of 
Sakai.  This can be run deep in the code tree at any maven node
that can compile (i.e. has a pom.xml).   You can actually put this in your
~/bin path and then just type ./smv.sh to do a re-compile into 
your Tomcat.  

A surprising amount of Sakai development can be done without
rebooting your Sakai.  If you are working on tool code, generally you can 
recompile without a reboot.  Changes to APIs in shared or components/services
generally require a Tomcat bounce.


Setting up Nightly Builds
=========================

There is a lot of flexibility inherent in creating config.sh and/or
sakai.properties that lets you set up a bunch of nightlies running 
on the same server and then having crontab entries to run things 
at whatever period(s) you desire.  You can set up different databases, 
different TCP ports, log to some Apache web space, even use Oracle
instead of MySql with some effort.  The script nightly.sh is pretty 
much ready to handle the job once the configuration is in place.

You can test all the scripts separately as you are configuring things
and then nightly.sh knits them together.

nightly.sh
----------

This script just calls the other scripts in the right order.  The script
does a checkout, shuts down any tomcat (killing if nexeccary), creates a new 
empty database, creates a fresh tomcat, checks out the code you want to compile,
compiles the code and starts Tomcat.   Since the script stops and starts the
right Tomcat automatically, you can run this script over and over interactively
in a cron job. 






