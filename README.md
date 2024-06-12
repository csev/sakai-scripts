Sakai-Scripts
=============

Some scripts that I use to make my life as a Sakai developer easier.

This is a set of scripts to set up a developer instance of Sakai on
your system or set up a nighly build.  Sakai can run on a 2GB RAM system
but is a lot more comfortable with a 4GB or more app server.

The outlie of this document is that you jump to the setup for Docker,
Ubuntu, Mac, or WSL and do some pre-steps and then continue with the
common steps, below.

Getting started on ubuntu in Docker
======================================

A quick way to test all this if you have this is to just make a ubuntu in your docker:

    docker run -it -p 8080:8080 ubuntu

You might want to give your docker images 4GB - ubuntu + Sakai does not fit into 2GB.

Getting Started on Ubuntu Linux
===============================

* Install git using the command

        apt-get update
        apt-get -y install git curl unzip zip vim

* Check out sakai-scripts into some folder and then install the rest of the pre-reqs

        cd
        git clone https://github.com/csev/sakai-scripts
        cd sakai-scripts
        bash ubuntu.sh
        source ~/.sdkman/bin/sdkman-init.sh

* If this is a fresh setup and you have no database you can do the following:

        apt-get -y install mariadb-server
        apt-get -y install mariadb-client
        service mysql start

Continue with the common steps below.


Getting Started on Mac (as needed)
==================================

* Install git using the command

        xcode-select --install

* Make sure you have Java-11 JDK (not JRE) Installed 

        java -version
        javac -version

* If you need a JDK-11 is is easiest to use using https://sdkman.io/
    
        curl -s "https://get.sdkman.io" | bash
        source ~/.sdkman/bin/sdkman-init.sh
        sdk install java 11.0.16-tem
    
* Make sure you have Maven (mvn) 3.8 or later installed. If you have Homebrew installed, you can use

        sdk install maven
        source ~/.sdkman/bin/sdkman-init.sh
 
* Check out sakai-scripts into some folder.   I tend to make a folder
named "dev" in my home directory:

        cd
        mkdir dev  (if needed)
        cd dev
        git clone https://github.com/csev/sakai-scripts

* If you need a database, install MAMP or something else if you have not already done so

Continue working with the Common steps below.

Getting Started with WSL for Sakai Developers
=============================================

Install WSL and Ubuntu.  There are lots of good sources on the Internet
on how to do this but there are some sticking points where you might get
stuck:

* Make sure Virtualization is enabled in your BIOS - it usually is off to
be more secure - but if it is not on WSL2 will break with lots of cryptic
messages - just boot into the BIOS and enable it.

* Go into Start -> Control Panel -> Programs -> Programs and Features and enable `Virtual
Machine Platform`, `Hyber-V` (Win11), and `Windows Subsystem for Linux` - The WSL option
might only show up after you install WSL.

You can install WSL and Ubuntu from the Windows Application Store or
using the `wsl` command in the command line (Start -> cmd).  

    wsl --install

You may need to restart your system, then do Start -> WSL - the first time
after install you will need to make a Linux User and Password.  Don't forget these.
Once you can log into WSL and see a prompt like:

    csev@WSLSakaiger:~$

You are in.  We are going to install Tsugi in order to get Apache, PHP, MySQL,
and PHPMyAdmin installed into your WSL.

    sudo bash
    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git
    cd tsugi-build
    bash ubuntu/build-dev.sh

Once the software has been installed you need to configure the installation.  This will be
a localhost only setup with no access to port 3306 from the Internet.

    cd /root
    cp tsugi-build/ubuntu/ubuntu-env-dev.sh ubuntu-env.sh
    source ubuntu-env.sh
    bash /usr/local/bin/tsugi-dev-configure.sh return
    
Then in a Windows browser navigate to:

    http://localhost/phpMyAdmin

Login as `root` / `root` And verify there is a `tsugi` database.

Navigate to 

    http://localhost/tsugi/admin

The admin unlock is `tsugi` - you should see the Tsugi Administration Console.  This verifies
the PHP, MySQL, Tsugi, PHPMyAdmin, and Apache installs are working and accessible from Windows.

Our next step is to install the Sakai scripts and dependencies.

    sudo bash
    cd /root
    git clone https://github.com/csev/sakai-scripts
    cd sakai-scripts
    bash ubuntu.sh
    source ~/.sdkman/bin/sdkman-init.sh

Verify that Java is installed with:

    java --version

It should respond with something like:

    openjdk 11.0.12 2021-07-20

Continue with the common steps below.  Note we are doing all the steps
below in WSL as root.

Common Steps For Ubuntu, WSL, and Mac
=====================================

You can either run your own fork of Sakai, if you want to make PR's or run your
own branches.   But if you are just getting started you can just checkout the Sakai
repo and run it - skip straight to "Compiling and Running Sakai".

Using Your Fork
---------------

Skip this section if you just want to checkout the main Sakai repository and
get it running.

* If you want to run your own fork, create an account on github 
and go to https://github.com/sakaiproject/sakai and "fork" a copy into
your github account

* If you want to push commits to your fork, set up git with the folowing commands

        git config --global user.name "John Doe"
        git config --global user.email johndoe@example.com

* Open a teminal and navigate to the sakai-scripts directory and:

        cp config-dist.sh config.sh

* Edit config.sh with a text editor of your choice

    * Start at "Settings start here"
    * Change "sakaiproject" in the GIT REPO  variable to be your github account if you want to run your fork
    * If you are not running MAMP or MariaDB, edit the MySQL root password, urls, ports, etc

The configuration knows about WSL and the `super` account so if you followed those
instructions above `config.sh` auto-detects WSL and follows that convention.

Compiling and Running Sakai
---------------------------

(If you are in WSL make sure to be runnning as root with an `sudo bash`)

* Make a copy of the ditributed `sakai.properties` and edit with the editor of your choice.

    cp sakai-dist.properties sakai.properties

* If you don't already have a database set up, make sure your MariaDB, MAMP or XAMPP is running
and run `bash db.sh` to create a database. This script lists the databases so you should
see `sakai23` as one of the databases if things work.  **Note**: If you run
`bash db.sh`  more than once it will drop and re-create the database.

        Active MySQL Databases:
        Database
        information_schema
        mysql
        performance_schema
        sakai23

        You will need add / update these lines in your sakai.properties

        username@javax.sql.....
        password@javax.sql.....
        url@javax.sql....

At the end of `db.sh` it prints out three lines that need to insert into `sakai.properties`.

Make sure to edit your copy of `sakai.properties` and edit/update the database strings before creating the Tomcat

* Run `bash na.sh` to set up the Tomcat

* Run `bash co.sh` to check the Sakai source code out (which repo is checked out
is in `config.sh`)

* Run `bash qmv.sh` to compile it all - the first time you do this it will take
a long time and use a lot of network bandwidth as it downloads a bunch of
library code in maven.   The first full compile might take 20+ minutes - later
full compiles will be about 2-3 minutes and partial compiles are 30 seconds or
less.  If the compile fails due to a download - just run `bash qmv.sh` again

* Run `bash start.sh` to start the Tomcat

* Run `bash tail.sh` to watch the logs (Press CTRL-C to stop the tail)

* Navigate to http://localhost:8080/portal

* To shut Sakai down, in the `tail.sh` terminal window, press `CTRL-C` and run bash `stop.sh` to shutdown Tomcat

* Copy `smv.sh` into a folder in your PATH and set execute permission
so you can recompile any sub-folder in Sakai that has a pom.xml
by typing "smv.sh".  The `smv.sh` command simply looks through your
path to find the correct value for `maven.tomcat.home` and sets up some
JAVA environment variables.

Description of the Scripts
==========================

Here are the scripts to be run in roughly the following order:

ubuntu.sh
---------

This runs a bunch of apt-get commands to load the pre-requisites for Sakai
for Ubuntu.  If you are running something other than Ubuntu, you can look
at this and use whatever package manager that is on the system to
install the necessary pre-requisites.  

config-dist.sh
--------------

This is a configuration script that sets a few parameters.  If you want/
need to tweak the parameters simply copy this to config.sh so git does
not try to check it in.  If there is a config.sh, it will be used instead
of config-dist.sh.

Generally you need to change the git repo to be checked out and the
root mysql password for non-MAMP MySQL connections.

But there is a lot of flexibility here if you are setting up nightly build
servers.   Changing things like the HTTP port, shutdown port, and location
of the Tomcat logs in config.sh allows you check these scripts out
into several directories and make different nightly builds.  If you get
really tricky, you can override sakai-dist.properties by copying it to
sakai.properties (which git will ignore) and change lots of things like
switching from MySql to Oracle.  

Note that db.sh does not understand oracle so if you are running oracle,
you might want to change MYSQL\_COMMAND to be "cat" so it does not try
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
Check to see if a database is there and create it if necessary.

na.sh
-----

Download and create a fresh instance of Tomcat, patch configurations,
and set up a sakai.properties

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

Developer Re-Compiles
=====================

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
does a checkout, shuts down any tomcat (killing if necessary), creates a new
empty database, creates a fresh tomcat, checks out the code you want to compile,
compiles the code and starts Tomcat.   Since the script stops and starts the
right Tomcat automatically, you can run this script over and over interactively
or in a cron job.






