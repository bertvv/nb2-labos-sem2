#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

configure

# Fix for error "INIT: Id "TO" respawning too fast: disabled for 5 minutes"
delete system console device ttyS0

#
# Basic settings
#
set system host-name 'Router'
#set service ssh port '22'

#
# IP settings
#
set interfaces ethernet eth0 description 'WAN'
set interfaces ethernet eth0 address dhcp

set interfaces ethernet eth1 description 'DMZ'
set interfaces ethernet eth1 address '192.168.15.254/24'

#set system gateway-address 10.0.2.2
#set system name-server 192.168.15.2
set system name-server 192.168.15.254

#
# Network Address Translation
#
set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '192.168.15.0/24'
set nat source rule 100 translation address 'masquerade'

#
# Time
#
set system time-zone 'Europe/Brussels'

delete system ntp server '0.pool.ntp.org'
delete system ntp server '1.pool.ntp.org'
delete system ntp server '2.pool.ntp.org'

set system ntp server '0.be.pool.ntp.org'
set system ntp server '1.be.pool.ntp.org'
set system ntp server '2.be.pool.ntp.org'

#
# Domain Name Service
#
#reset dns forwarding all
set service dns forwarding name-server 10.0.2.3
set service dns forwarding domain linuxlab.lan server 192.168.15.2
set service dns forwarding listen-on 'eth1'

commit
save

# Fix permissions on configuration
sudo chown -R root:vyattacfg /opt/vyatta/config/active

# vim: set ft=sh
