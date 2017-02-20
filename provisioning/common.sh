#! /usr/bin/bash
#
# Provisioning script common for all servers

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
# TODO: put all variable definitions here. Tip: make them readonly if possible.

# Name of the admin user. Exporting makes it available in the server specific
# scripts.
export readonly ADMIN_USER=bert

#------------------------------------------------------------------------------
# Ensure machine id is created
#------------------------------------------------------------------------------
# Journald needs the file /etc/machine-id in order to work. This checks if that
# file exists, and initialises it if necessary
if [ ! -f /etc/machine-id ]; then
  info 'Generating machine ID'
  systemd-machine-id-setup
fi

#------------------------------------------------------------------------------
# Package installation
#------------------------------------------------------------------------------
# TODO: install packages required on all servers

info Starting common tasks

info Restarting network interfaces
systemctl restart network

info Installating common packages

#------------------------------------------------------------------------------
# Admin user
#------------------------------------------------------------------------------
# TODO: set up a user account that you can use to log in to the server. Ensure
# your user can login with ssh without having to enter a password (using a key
# pair).

info Setting up admin user account
ensure_user_exists "${ADMIN_USER}"


