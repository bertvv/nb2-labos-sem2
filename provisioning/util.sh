#! /usr/bin/bash
#
# Utility functions that are useful in all provisioning scripts.

#------------------------------------------------------------------------------
# Logging and debug output
#------------------------------------------------------------------------------

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "### %s\n" "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "!!! %s\n" "${*}" 1>&2
}


#------------------------------------------------------------------------------
# Useful tests
#------------------------------------------------------------------------------

# Usage: files_differ FILE1 FILE2
#
# Tests whether the two specified files have different content
#
# Returns with exit status 0 if the files are identical, a nonzero exit status
# if they differ
files_differ() {
  local file1="${1}"
  local file2="${2}"

  # If the second file doesn't exist, it's considered to be different
  if [ ! -f "${file2}" ]; then
    return 0
  fi

  local -r checksum1=$(md5sum "${file1}" | cut -c 1-32)
  local -r checksum2=$(md5sum "${file2}" | cut -c 1-32)

  [ "${checksum1}" != "${checksum2}" ]
}


#------------------------------------------------------------------------------
# SELinux
#------------------------------------------------------------------------------

# Usage: ensure_sebool VARIABLE
#
# Ensures that an SELinux boolean variable is turned on
ensure_sebool()  {
  local -r sebool_variable="${1}"
  local -r current_status=$(getsebool "${sebool_variable}")

  if [ "${current_status}" != "${sebool_variable} --> on" ]; then
    setsebool -P "${sebool_variable}" on
  fi
}

#------------------------------------------------------------------------------
# User management
#------------------------------------------------------------------------------

# Usage: ensure_user_exists USERNAME
#
# Creates the user with the specified name if it doesn’t exist
ensure_user_exists() {
  local user="${1}"
  info "Ensure user ${user} exists"
  if ! getent passwd "${user}"; then
    info " -> user added"
    useradd "${user}"
  else
    info " -> already exists"
  fi
}

# Usage: ensure_group_exists GROUPNAME
#
# Creates the group with the specified name, if it doesn’t exist
ensure_group_exists() {
  local group="${1}"

  info "Ensure group ${group} exists"
  if ! getent group "${group}"; then
    info " -> group added"
    groupadd "${group}"
  else
    info " -> already exists"
  fi
}

# Usage: assign_groups USER GROUP...
#
# Adds the specified user to the specified groups
assign_groups() {
  local user="${1}"
  shift
  info "Adding user ${user} to groups: ${*}"
  while [ "$#" -ne "0" ]; do
    usermod -aG "${1}" "${user}"
    shift
  done
}

# Usage: samba_passwd USERNAME PASSWORD
#
# Ensures that the Samba user with the specified name exists and is assigned
# the specified password
set_samba_passwd() {
  local user="${1}"
  local password="${2}"
  info "Create Samba password for user ${user}"
    (pdbedit -L | grep "${user}" > /dev/null 2>&1 ) \
      || (echo "${password}"; echo "${password}") \
      | smbpasswd -s -a "${user}"
}

#-----------------------------------------------------------------------------
# Samba
#-----------------------------------------------------------------------------

# Usage: setup_samba_share SHARE SAMBA_ROOT [MODE [CONTEXT]]
#
# Creates a directory for a Samba share, assings a group, and optionally 
# sets permissions and SELinux context 
create_samba_share() {
  share="${1}"
  root_dir="${2}"
  mode="${3:-775}"
  context="${4:-samba_share_t}"
  share_dir="${root_dir}/${share}"

  info "Setting up share ${share}"

  if [ ! -d "${share_dir}" ]; then
    info "Creating directory ${share_dir}"
    mkdir -p "${share_dir}"
  fi

  ensure_group_exists "${share}"

  info "Setting permissions"
  chgrp "${share}" "${share_dir}"
  chmod "${mode}" "${share_dir}"
  chcon --recursive --type \
    "${context}" "${share_dir}"
}

