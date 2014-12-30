Use this folder to add jars that need to be included in the 
common/lib folder in the Tomcat folder

You would need to get your hands on the mysql connector, perhaps
a command similar to this would work:

    curl -O http://afs.dr-chucx.com/download/mysql-connector-java-5.1.6-bin.jar

Once this is downloaded, it will just sit in the jars folder
and be ignored by git and used by the na.sh process.
