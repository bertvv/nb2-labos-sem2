#! /usr/bin/bash
#
# Provisioning script for srv001

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't mask errors in piped commands
set -o pipefail

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
export readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

readonly dhcp_conf="${PROVISIONING_FILES}/etc_dhcp_dhcpd.conf"

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Utility functions
source ${PROVISIONING_SCRIPTS}/util.sh
# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

info "Starting server specific provisioning tasks on ${HOSTNAME}"

info "Installing packages"

yum -y install dhcp

info "Configuring firewall"

firewall-cmd --permanent --add-interface enp0s8
firewall-cmd --permanent --add-service dhcp
systemctl restart firewalld.service

info "Configuring DHCP"

if files_differ "${dhcp_conf}" /etc/dhcp/dhcpd.conf ; then
  # First, check the config file (provisioning script will fail if errors are found)
  dhcpd -t -cf "${dhcp_conf}" 2> /dev/null

  cp "${dhcp_conf}" /etc/dhcp/dhcpd.conf
  if systemctl is-active dhcpd.service; then
    systemctl restart dhcpd.service
  fi
else
  echo "    ... no changes"
fi

ensure_service_running dhcpd.service
