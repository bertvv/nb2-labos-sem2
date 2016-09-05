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
# Package installation
#------------------------------------------------------------------------------
# TODO: install packages required on all servers

info Starting common tasks
info Installating common packages

#------------------------------------------------------------------------------
# Admin user
#------------------------------------------------------------------------------
# TODO: set up a user account that you can use to log in to the server. Ensure
# your user can login with ssh without having to enter a password (using a key
# pair).

info Setting up admin user account
ensure_user_exists "${ADMIN_USER}"


