#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

configure

# Fix for error "INIT: Id "TO" respawning too fast: disabled for 5 minutes"
delete system console device ttyS0

#------------------------------------------------------------------------------
# Basic settings
#------------------------------------------------------------------------------

# TODO: set the host name
set system host-name 'Router'

#------------------------------------------------------------------------------
# IP settings
#------------------------------------------------------------------------------
# TODO: Set up network interfaces

#------------------------------------------------------------------------------
# Network Address Translation
#------------------------------------------------------------------------------
# TODO: Set NAT rules

#------------------------------------------------------------------------------
# Time
#------------------------------------------------------------------------------

# Set time zone and use the Belgian NTP servers for synchronizing time
set system time-zone 'Europe/Brussels'

delete system ntp server '0.pool.ntp.org'
delete system ntp server '1.pool.ntp.org'
delete system ntp server '2.pool.ntp.org'

set system ntp server '0.be.pool.ntp.org'
set system ntp server '1.be.pool.ntp.org'
set system ntp server '2.be.pool.ntp.org'

#------------------------------------------------------------------------------
# Domain Name Service
#------------------------------------------------------------------------------

# First, reset all existing forwarding rules
reset dns forwarding all

# TODO: DNS requests for this domain should be forwarded to the master DNS
# server, all other requests should be forwarded to the DNS server of the NAT
# network

#------------------------------------------------------------------------------
# Clean up, commit changes
#------------------------------------------------------------------------------

commit
save

# Fix permissions on configuration
sudo chown -R root:vyattacfg /opt/vyatta/config/active

# vim: set ft=sh
