NOW TESTING THE SMTP

pc_vlan50_1:/# telnet mail.internet.com 25
Connected to mail.internet.com
220 mail.internet.com ESMTP Postfix (Debian/GNU)
ls -la
500 5.5.2 Error: command not recognized
cd
500 5.5.2 Error: command not recognized
dir
500 5.5.2 Error: command not recognized
help
500 5.5.2 Error: command not recognized
h
500 5.5.2 Error: command not recognized
^C
Console escape. Commands are:

 l	go to line mode
 c	go to character mode
 z	suspend telnet
 e	exit telnet
pc_vlan50_1:/# telnet mail.internet.com 25
Connected to mail.internet.com
220 mail.internet.com ESMTP Postfix (Debian/GNU)
HELO test.lab
250 mail.internet.com
MAIL FROM:<test@internet.com>
250 2.1.0 Ok
RCPT TO:<alice@enterprise.com>
250 2.1.5 Ok
DATA
354 End data with <CR><LF>.<CR><LF>
Subject: test
Some more contant to write goes here
.
250 2.0.0 Ok: queued as DB2F7623773




#### Now for sending mail
echo "hola" | msmtp alice@enterprise.com





---
TEST EVERYTHING:
c_vlan50_1:/# telnet enterprise.com 25
MAIL FROM:<alice@enterprise.com>
RCPT TO:<external@internet.com>
DATA
Subject: test
hi!  
.
QUIT



DESPRES: (des de dins de la xarxa)
telnet internet.com 143
a login <name> <pswd>

a select INBOX

a fetch 1 full
---

ONLY LOCAL
benign:/# telnet internet.com 25
Connected to internet.com
220 mail.internet.com ESMTP Postfix (Debian/GNU)
MAIL FROM:<external@internet.com>
250 2.1.0 Ok
RCPT TO:<external@internet.com>
250 2.1.5 Ok
DATA
354 End data with <CR><LF>.<CR><LF>
Hola, aixo es una prova
.
250 2.0.0 Ok: queued as 87AE962367D
QUIT
221 2.0.0 Bye
Connection closed by foreign host
benign:/#


# This commands recovers the email, now, we are trying internet-internet, IT WORKS
# The number is the number of email
a fetch 1 rfc822
a fetch * rfc822




-----

To use, mutt
set the mail and so on, on the editor :wq to save.













Logs form device
```bash
docker logs clab-virtual-env-internal_server
```

Connect to device
```bash
docker exec -it clab-virtual-env-pc_vlan50_1 bash
```

View all services from a device
```bash
service --status-all
```

Request DHCP
```bash
dhcpcd -4 -d eth1
```

pc_admin:/# curl http://enterprise.local
Hello from Nginx on the web server

pc_vlan50_1:/# curl http://enterprise.local
Hello from Nginx on the web server

cat /etc/resolv.conf
nslookup enterprise.local
nslookup 192.168.10.10
dig www.enterprise.local

tcpdump -i eth1 -f 'port 67 or port 68'

DNS INTERN  - 192.168.10.10
            - 192.168.40.10

DNS EXTERN  - 172.16.100.100
            - 172.16.30.2


pc_vlan50_2:/# nslookup enterprise.local
Server:		192.168.10.10
Address:	192.168.10.10#53

Name:	enterprise.local
Address: 192.168.10.10

pc_vlan50_2:/# nslookup enterprise.com
Server:		192.168.10.10
Address:	192.168.10.10#53

Name:	enterprise.com
Address: 192.168.10.10

pc_vlan50_2:/# nslookup internet.com
Server:		192.168.10.10
Address:	192.168.10.10#53

Name:	internet.com
Address: 172.16.100.100

pc_vlan50_2:/# 
