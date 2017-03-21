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

readonly shares_root=/srv/shares

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
  samba \
  samba-client

info "Starting Samba services"

systemctl start nmb
systemctl enable nmb
systemctl start smb
systemctl enable smb

info "Configuring firewall"

firewall-cmd --add-service=samba --permanent
firewall-cmd --reload

info "Create shares"
if [ ! -d "${shares_root}" ]; then
  mkdir "${shares_root}"
fi
create_samba_share public     "${shares_root}"
create_samba_share technical  "${shares_root}"
create_samba_share financial  "${shares_root}" '0770'
create_samba_share management "${shares_root}" '0770'

info "Configuring samba"
setsebool -P samba_export_all_rw on

if files_differ "${PROVISIONING_FILES}/smb.conf" "/etc/samba/smb.conf"; then

  info "New config file: checking syntax"
  testparm -s "${PROVISIONING_FILES}/smb.conf"

  info "Copying to /etc"
  cp "${PROVISIONING_FILES}/smb.conf" "/etc/samba/smb.conf"

  info "Restarting services"
  systemctl restart nmb
  systemctl restart smb
fi


