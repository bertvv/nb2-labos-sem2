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
readonly admin_passwd='$6$9hUev.agoxZru1Aa$JHhPWJyymtrdTQjsXZuLzsJqsmxhZLJUOVSpsGCbhB52MMqpLGjYlW7oyWRkcHSgVnvwRvqdsaSbedAt0Wk.90'

readonly public_key='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoJcKFIfhaDejJVlNJof6UVJHkTlFwZ7UByQ4DCAwve33oAsDIZomTS4aPWLlBOFczIlUsFIfFFu0vo2kXt23uI433qXLIZcpNe7R0gbS6z7CljkELGghgpXMnI7apMwtIt2hfpz+ddOwu1GRPD+gr/7IOPRHaH2dehq/tf3LT5qOsr07g3qQWbqgzM6QuClRONh+BPqRXMRgyZZbtoubImGlBrmYMaBFlkL7/7SXn0JP2d6MtSoRwYGyz0zUJKStnrsVey3cZ/P1h4XyQ5JF2CG7BIIzlN6LoH7BeNKake1IX8UZ8gvvc1nGQkaH/yezCDGQIYWIrcSX5uV+53K6N bert@emrakul'
readonly dot_ssh="/home/${ADMIN_USER}/.ssh"
readonly keys="${dot_ssh}/authorized_keys"


#------------------------------------------------------------------------------
# Package installation
#------------------------------------------------------------------------------

info Starting common tasks
info Installating common packages

yum install -y epel-release
yum install -y bind-utils git nano tree vim-enhanced

#------------------------------------------------------------------------------
# Admin user
#------------------------------------------------------------------------------

info Setting up admin user account
ensure_user_exists "${ADMIN_USER}"

usermod --password="${admin_passwd}" "${ADMIN_USER}"

assign_groups "${ADMIN_USER}" wheel

# Copy public key

if [ ! -d "${dot_ssh}" ]; then
  info 'Creating .ssh directory'
  mkdir "${dot_ssh}"
  chown ${ADMIN_USER}:${ADMIN_USER} "${dot_ssh}"
  chmod u=rwx,go= "${dot_ssh}"
fi

info 'Copying public key'
echo "${public_key}" > "${keys}"
chown ${ADMIN_USER}:${ADMIN_USER} "${keys}"
chmod u=rw,go= "${keys}"

