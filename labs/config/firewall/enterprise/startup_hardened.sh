# =================================================================================================
# Rate Limiting (variant - still allows attacks to be detected, not silently dropped)
# =================================================================================================

# SSH rate limiting
iptables -A FORWARD -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH_RATE
iptables -A FORWARD -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 30 --name SSH_RATE -j DROP

# ICMP rate limiting
iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 10/sec --limit-burst 20 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type echo-request -j DROP

# SYN rate limiting
iptables -A FORWARD -p tcp --syn -m limit --limit 200/sec --limit-burst 400 -j ACCEPT
iptables -A FORWARD -p tcp --syn -j DROP
