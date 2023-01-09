I love Cloudflare.  I use it extensively for any production server I support.  I use it for https
termination, DDOS mitigation, performance improvement for static content, super flexible DNS management
and many more things.

In building my support for IMS LTI Advantage I decided I just needed a server that would run a particular
tag or branch of Sakai in production for basic testing rather than pushing everything to master and waiting
until the nightly server went through the rebuild.

Here are my notes on putting Sakai behind Cloudflare.

- In CloudFlare under "Overview" Make sure SSL is "Flexible" to keep CloudFlare talking on the backend on port 80

- In CloudFlare, Make a rule for "Automatic HTTPS Rewrites"

- In CloudFlare make a rule that matches

    *.sakaicloud.com/webcomponents/*
    Cache Level: Cache Everything, Opportunistic Encryption: On

    *.sakaicloud.com/library/*
    Cache Level: Cache Everything, Opportunistic Encryption: On

    *.sakaicloud.com/imsblis/*
    Browser Integrity Check: Off, Always Online: Off, Security Level: Essentially Off, Cache Level: Bypas

- In the Sakai server in the file ./apache-tomcat-8.0.30/conf/server.xml set up the connector like this

<Connector port="80" 
    protocol="HTTP/1.1"   
    connectionTimeout="20000" 
    scheme="https"  />

This runs an http (port 80) without requiring any key fussing.  Since Cloudflare does the SSL we don't need it
in Tomcat.   See 

    https://tomcat.apache.org/tomcat-7.0-doc/config/http.html#SSL_Support

If you want to run your Sakai on port 8080 (i.e. not root) but CloudFlare insists on 80, you
can do the following trick on your Linux box as root:

iptables -A INPUT -i eth0 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 8080 -j ACCEPT
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080

This will need to be redone whenever the system restarts.

Thanks to https://iwearshorts.com/blog/redirect-port-80-to-8080-using-iptables/

Interestingly, one thing I did not need to do was adjust the caching for the "/library" urls
in Sakai.   Sakai sets all the headers so well that Cloudflare needs no further guidance and neither
does the browser.  Just as a simple test, the actual un-cached download for the initial page in Sakai
prior to login is 8.8KB.  That is *KILO-BYTES*.  A normal post-login page in Sakai's Lessons is 31.4 KB
data transferred. Amazingly low bandwidth usage for an enterprise application like Sakai.

Pretty cool.



