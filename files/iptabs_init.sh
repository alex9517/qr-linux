#!/bin/bash
#
# Created  : 2018-Oct-26
# Modified : 2021-Mar-17
#
# Description :
#  this script sets basic firewall rules;
# ---------------------------------------
# 127.0.0.1 - 0:0:0:0:0:ffff:7f00:1
# 192.168.10.0 - 0:0:0:0:0:ffff:c0a8:a00
# 192.168.10.255 - 0:0:0:0:0:ffff:c0a8:aff
# range - 0:0:0:0:0:ffff:c0a8:a00/120

# 192.168.0.0 - 0:0:0:0:0:ffff:c0a8:0
# 192.168.0.255 - 0:0:0:0:0:ffff:c0a8:ff
# range - 0:0:0:0:0:ffff:c0a8:0/120

# 192.168.255.255 - 0:0:0:0:0:ffff:c0a8:ffff
# range - 0:0:0:0:0:ffff:c0a8:0/112

# 192.168.10.1 - 0:0:0:0:0:ffff:c0a8:a01
# 192.168.10.101 - 0:0:0:0:0:ffff:c0a8:a65

LINK_LOCAL_4=169.254.0.0/16
LINK_LOCAL_6=fe80::/10

MULTICAST_DNS_4=224.0.0.251
MULTICAST_DNS_6=ff02::fb

MULTICAST_SUB_4=224.0.0.0/24
MULTICAST_SUB_6=ffx2::/16

LOCAL_SUB_4=192.168.0.0/16
LOCAL_SUB_6=0:0:0:0:0:ffff:c0a8:0/112

TCP_PORT_NFS=2049
TCP_PORT_PSQL=5432
TCP_PORT_DLNA=8200
TCP_PORT_APP_SVC=8080
TCP_PORT_WEB_SVC=8443
TCP_PORT_PLEX=32400

UDP_PORT_DNS=53
UDP_PORT_MDNS=5353


iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

ip6tables -F
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

# A user-defined chain intended to prevent brute-force attacks;
# The limit is 10 new connections within 5 minutes from a single host;
# Suspicious attempts of brute-force will be logged;

iptables -N BRUTE
iptables -A BRUTE -m recent --name BRU --set
iptables -A BRUTE -m recent --name BRU --update --seconds 300 --hitcount 10 -m limit --limit 1/second --limit-burst 100 -j LOG --log-prefix "iptables[Brute Force?]: "
iptables -A BRUTE -m recent --name BRU --update --seconds 300 --hitcount 10 -j DROP
iptables -A BRUTE -j ACCEPT

ip6tables -N BRUTE
ip6tables -A BRUTE -m recent --name BRU --set
ip6tables -A BRUTE -m recent --name BRU --update --seconds 300 --hitcount 10 -m limit --limit 1/second --limit-burst 100 -j LOG --log-prefix "iptables[Brute Force?]: "
ip6tables -A BRUTE -m recent --name BRU --update --seconds 300 --hitcount 10 -j DROP
ip6tables -A BRUTE -j ACCEPT

# A user-defined chain intended to prevent ICMP and ICMP REPLY flooding;
# The limit is 6 pings/sec from a single source;

iptables -N ICMPFLOOD
iptables -A ICMPFLOOD -m recent --set --name ICMP --rsource
iptables -A ICMPFLOOD -m recent --update --seconds 1 --hitcount 6 --name ICMP --rsource --rttl -m limit --limit 1/sec --limit-burst 1 -j LOG --log-prefix "iptables[ICMP-flood]: "
iptables -A ICMPFLOOD -m recent --update --seconds 1 --hitcount 6 --name ICMP --rsource --rttl -j DROP
iptables -A ICMPFLOOD -j ACCEPT

ip6tables -N ICMPFLOOD
ip6tables -A ICMPFLOOD -m recent --set --name ICMP --rsource
ip6tables -A ICMPFLOOD -m recent --update --seconds 1 --hitcount 6 --name ICMP --rsource --rttl -m limit --limit 1/sec --limit-burst 1 -j LOG --log-prefix "iptables[ICMP-flood]: "
ip6tables -A ICMPFLOOD -m recent --update --seconds 1 --hitcount 6 --name ICMP --rsource --rttl -j DROP
ip6tables -A ICMPFLOOD -j ACCEPT

# Drop bad packets;

iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Drop remote pkts pretending to be from a loopback iface;

iptables -A INPUT ! -i lo -s 127.0.0.0/8 -j DROP
ip6tables -A INPUT ! -i lo -s ::1/128 -j DROP

# Accept everything from the loopback iface;

iptables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT

# Accept some types of ICMP packets;

iptables -A INPUT -p icmp --icmp-type 0 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 3 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ICMPFLOOD
iptables -A INPUT -p icmp --icmp-type 11 -m conntrack --ctstate NEW -j ACCEPT

# The following is required for IPv6 ICMP packet types according to RFC 4890;

# ip6tables -A INPUT -p icmpv6 -j ACCEPT

ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 1 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 2 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 3 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 4 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 128 -j ICMPFLOOD
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 133 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 134 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 135 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 136 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 137 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 141 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 142 -j ACCEPT
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 130 -j ACCEPT
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 131 -j ACCEPT
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 132 -j ACCEPT
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 143 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 148 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 149 -j ACCEPT
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 151 -j ACCEPT
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 152 -j ACCEPT
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 153 -j ACCEPT

# Allow Link-Local.
# NOTE! IPv6 nodes all have link-local addresses (fe80::/10);
#   nodes will use the link-local addressing for various things,
#   but all this remains within local net and cannot be routed;

iptables -A INPUT -s $LINK_LOCAL_4 -j ACCEPT
ip6tables -A INPUT -s $LINK_LOCAL_6 -j ACCEPT

# Allow multicast (for mDNS);

iptables -A INPUT -d 224.0.0.0/4 -j ACCEPT
ip6tables -A INPUT -d ff00::/8 -j ACCEPT

# iptables -A INPUT -d 224.0.0.251 -m pkttype --pkt-type multicast -j ACCEPT
# ip6tables -A INPUT -d ff02::fb -m pkttype --pkt-type multicast -j ACCEPT

# iptables -A INPUT -s 224.0.0.0/4 -j ACCEPT

# iptables -A INPUT -p udp --dport 5353 -m pkttype --pkt-type multicast -d 224.0.0.251 -j ACCEPT
# ip6tables -A INPUT -p udp --dport 5353 -m pkttype --pkt-type multicast -d ff02::fb -j ACCEPT

# iptables -A INPUT -m pkttype --pkt-type multicast -j ACCEPT

# iptables -A INPUT   -s 224.0.0.0/4 -j ACCEPT
# iptables -A FORWARD -s 224.0.0.0/4 -d 224.0.0.0/4 -j ACCEPT
# iptables -A OUTPUT -d 224.0.0.0/4 -j ACCEPT

# Accept packets belonging to earlier established connections;

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow access to SSH;

iptables -A INPUT -p tcp --dport 22 --syn -m conntrack --ctstate NEW -j BRUTE
ip6tables -A INPUT -p tcp --dport 22 --syn -m conntrack --ctstate NEW -j BRUTE

# Allow access to HTTP/HTTPS;

iptables -A INPUT -p tcp -s $LOCAL_SUB_4 -m multiport --dports 80,443 --syn -m conntrack --ctstate NEW -j ACCEPT
ip6tables -A INPUT -p tcp -s $LOCAL_SUB_6 -m multiport --dports 80,443 --syn -m conntrack --ctstate NEW -j ACCEPT

# Allow access to NFS server;

# iptables -A INPUT -p tcp -s $LOCAL_SUB_4 --dport $TCP_PORT_NFS --syn -m conntrack --ctstate NEW -j ACCEPT
# ip6tables -A INPUT -p tcp -s $LOCAL_SUB_6 --dport $TCP_PORT_NFS --syn -m conntrack --ctstate NEW -j ACCEPT

# PostgreSQL database server;

# iptables -A INPUT -p tcp -s $LOCAL_SUB_4 --dport $TCP_PORT_PSQL --syn -m conntrack --ctstate NEW -j ACCEPT
# ip6tables -A INPUT -p tcp -s $LOCAL_SUB_6 --dport $TCP_PORT_PSQL --syn -m conntrack --ctstate NEW -j ACCEPT

# Allow access to MiniDLNA (8200/tcp);

# iptables -A INPUT -p tcp -s $LOCAL_SUB_4 --dport $TCP_PORT_DLNA --syn -m conntrack --ctstate NEW -j ACCEPT
# ip6tables -A INPUT -p tcp -s $LOCAL_SUB_6 --dport $TCP_PORT_DLNA --syn -m conntrack --ctstate NEW -j ACCEPT

# Allow access to a tested web app (8080/tcp);

# iptables -A INPUT -p tcp -s $LOCAL_SUB_4 --dport $TCP_PORT_APP_SVC --syn -m conntrack --ctstate NEW -j ACCEPT
# ip6tables -A INPUT -p tcp -s $LOCAL_SUB_6 --dport $TCP_PORT_APP_SVC --syn -m conntrack --ctstate NEW -j ACCEPT

# Allow access to a tested web service (8443/tcp);

# iptables -A INPUT -p tcp -s $LOCAL_SUB_4 --dport $TCP_PORT_WEB_SVC --syn -m conntrack --ctstate NEW -j ACCEPT
# ip6tables -A INPUT -p tcp -s $LOCAL_SUB_6 --dport $TCP_PORT_WEB_SVC --syn -m conntrack --ctstate NEW -j ACCEPT

# Plex Media Server (32400/tcp);

# iptables -A INPUT -p tcp -s $LOCAL_SUB_4 --dport $TCP_PORT_PLEX --syn -m conntrack --ctstate NEW -j ACCEPT
# ip6tables -A INPUT -p tcp -s $LOCAL_SUB_6 --dport $TCP_PORT_PLEX --syn -m conntrack --ctstate NEW -j ACCEPT

# Allow connections to ports beyond 1024 from the LAN hosts;

iptables -A INPUT -p udp -s $LOCAL_SUB_4 --dport 1024: -j ACCEPT
iptables -A INPUT -p tcp -s $LOCAL_SUB_4 --dport 1024: --syn -m conntrack --ctstate NEW -j ACCEPT

ip6tables -A INPUT -p udp -s $LOCAL_SUB_6 --dport 1024: -j ACCEPT
ip6tables -A INPUT -p tcp -s $LOCAL_SUB_6 --dport 1024: --syn -m conntrack --ctstate NEW -j ACCEPT

# -END-
