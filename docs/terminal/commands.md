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
