Sakai-Scripts
=============

A Repo of my scripts that I use to make my life as a Sakai developer easier

This is a set of scripts to set up a developer instance
of Sakai on your system.  Sakai can run on a 2GB RAM system
but is a lot more comfortable with a 4GB app server.

Make sure to add this to your .profile so your mavens and Sakai can 
run.

    JAVA_OPTS='-server -Xms512m -Xmx1024m -XX:PermSize=128m -XX:MaxPermSize=512m 
    -XX:NewSize=192m -XX:MaxNewSize=384m -Djava.awt.headless=true -Dhttp.agent=Sakai 
    -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false 
    -Dsun.lang.ClassLoader.allowArraySyntax=true'

    export JAVA_OPTS

    MAVEN_OPTS='-Xms512m -Xmx1024m -XX:PermSize=128m -XX:MaxPermSize=512m'

    export MAVEN_OPTS

Initial Install
===============

Here are the scripts to be run in roughly the following order:

ubuntu.sh
---------

This runs a bunch of apt-get commands to load the pre-requisites for Sakai
for Ubuntu.  If you are running something else, you can look at this and 
use whatever package manager that is on the system to install the necessary
pre-requisites.

TODO: OS/X pre-requisite instructions.

config-dist.sh
--------------

This is a configuration script that sets a few parameters.  If you want/
need to tweak the parameters simply copy this to config.sh so git does
not try to check it in.  If there is a config.sh, it will be used instead
of config-dist.sh.

db.sh
-----
This sets up a database with an account and password based on the contents
of config.sh

co.sh
-----

Checkout all of the Sakai source into the folder trunk.   This checks out
the main Sakai source and a few projects that Sakai depends on in case you
want to peruse the source of those projects.

na.sh
-----

Download and create a fresh instance of Tomcat.  
After this is done, you will want to create a folder 

    apache-tomcat-7.0.21/sakai/

And copy the sakai.properties into the folder.  Edit as appropriate.  Likely 
the only thing to change is to get the MySQL port fixed depending on whether 
you use MAMP (port 8889) or MySQL (port 3306)

Make a folder:

    apache-tomcat-7.0.21/common/lib/

Since we cannot include the MySQL connector, download a copy of the 
MySQL JDBC connector from:

    http://dev.mysql.com/downloads/connector/j/

Once you download and unzip the connector copy the jar into the
common/lib folder above.  My Jar file looks as follows:

    mysql-connector-java-5.1.6-bin.jar

qmv.sh
------

Compile all of the Sakai source bypassing unit tests.   This saves a lot
of time in the initial compile.   The mv.sh will compile with unit test.
Once things work and you need to go out for an errand, you can run a mv.sh 
to compile with all unit tests.

Starting and Re-Starting Sakai
==============================

Once the compile is finished, and you have MySQL installed, to start Sakai
go into the folder:

    apache-tomcat-7.0.21/logs

And run the following commands:

    ../bin/startup.sh
    tail -f catalina.out

You should be able to watch the log as Sakai starts up.  If things
go well you should see this in the logs:

And at this point, you should be able to navigate a browser to:

    http://localhost:8080/portal

If you need to recompile, the steps to shut down Sakai are to first
abort your tail command with a CTRL-C and then

    ../bin/shutdown.sh

Usually to keep thins clean, I remove all the files in the Tomcat logs
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



