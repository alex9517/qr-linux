#!/bin/bash
#
# Created  : 2018-Oct-27
# Modified : 2018-Oct-27
#
# Description :
#  this script removes firewall rules;
# ------------------------------------

iptables -F
iptables -F BRUTE
iptables -X BRUTE
iptables -F ICMPFLOOD
iptables -X ICMPFLOOD

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

ip6tables -F
ip6tables -F BRUTE
ip6tables -X BRUTE
ip6tables -F ICMPFLOOD
ip6tables -X ICMPFLOOD

ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT

# -END-
