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

readonly dnsmasq_conf=/etc/dnsmasq.conf
readonly hosts_file=/etc/hosts

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

yum install -y \
  dnsmasq

info "Starting Dnsmasq service"

systemctl start dnsmasq
systemctl enable dnsmasq

info "Configuring firewall"

firewall-cmd --add-service=dns --permanent
firewall-cmd --reload

info "Configuring Dnsmasq"

if files_differ "${PROVISIONING_FILES}/hosts" "${hosts_file}"; then
  info "Copying hosts file"
  cp "${PROVISIONING_FILES}/hosts" "${hosts_file}"
  systemctl restart dnsmasq.service
fi

if files_differ "${PROVISIONING_FILES}/dnsmasq.conf" "${dnsmasq_conf}"; then
  info "Copying dnsmasq.conf"
  cp "${PROVISIONING_FILES}/dnsmasq.conf" "${dnsmasq_conf}"
  systemctl restart dnsmasq.service
fi
