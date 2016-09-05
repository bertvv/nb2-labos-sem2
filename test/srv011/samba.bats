#! /usr/bin/env bats
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Acceptance test for a Samba server


sut_ip=192.168.15.11   # IP of the system under test
sut_wins_name=files    # NetBIOS name
workgroup=LINUXLAB     # Workgroup
admin_user=bert        # Name of the administrator (acces to all shares)

# Root directory of Samba shares
samba_share_root=/srv/shares
# The name of a directory and file that will be created to test for
# write access (= random string)
test_dir=peghawJaup
test_file=Nocideicye

# {{{Helper functions

teardown() {
  # Remove all test directories and files
  find "${samba_share_root}" -maxdepth 2 -type d -name "${test_dir}" \
    -exec rm -rf {} \;
  find "${samba_share_root}" -maxdepth 2 -type f -name "${test_file}" \
    -exec rm {} \;
  rm -f "${test_file}"
}

# Check that a user has read acces to a share
# Usage: read_access SHARE USER PASSWORD
assert_read_access() {
  local share="${1}"
  local user="${2}"
  local password="${3}"

  run smbclient "//${sut_wins_name}/${share}" \
    --user=${user}%${password} \
    --command='ls'
  [ "${status}" -eq "0" ]
}

# Check that a user has NO read access to a share
# Usage: no_read_access SHARE USER PASSWORD
assert_no_read_access() {
  local share="${1}"
  local user="${2}"
  local password="${3}"

  run smbclient "//${sut_wins_name}/${share}" \
    --user=${user}%${password} \
    --command='ls'
  [ "${status}" -eq "1" ]
}

# Check that a user has write access to a share
# Usage: write_access SHARE USER PASSWORD
assert_write_access() {
  local share="${1}"
  local user="${2}"
  local password="${3}"

  run smbclient "//${sut_wins_name}/${share}" \
    --user=${user}%${password} \
    --command="mkdir ${test_dir};rmdir ${test_dir}"
  # Output should NOT contain any error message. Checking on exit status is
  # not reliable, it can be 0 when the command failed...
  [ -z "$(echo ${output} | grep NT_STATUS_)" ]
}

# Check that a user has NO write access to a share
# Usage: no_write_access SHARE USER PASSWORD
assert_no_write_access() {
  local share="${1}"
  local user="${2}"
  local password="${3}"

  run smbclient "//${sut_wins_name}/${share}" \
    --user=${user}%${password} \
    --command="mkdir ${test_dir};rmdir ${test_dir}"
  # Output should contain an error message (beginning with NT_STATUS, usually
  # NT_STATUS_MEDIA_WRITE_PROTECTED
  [ -n "$(echo ${output} | grep NT_STATUS_)" ]
}

# Check that users from the same group can write to each other’s directories
# Usage: assert_group_write SHARE USER1 PASSWD1 USER2 PASSWD2
assert_group_write_file() {
  local share="${1}"
  local user1="${2}"
  local passwd1="${3}"
  local user2="${4}"
  local passwd2="${5}"

  echo "Hello world!" > ${test_file}

  smbclient "//${sut_wins_name}/${share}" --user=${user1}%${passwd1} \
    --command="put ${test_file}"
  # In order to overwrite the file, write access is needed. This will fail
  # if user2 doesn’t have write access.
  smbclient "//${sut_wins_name}/${share}" --user=${user2}%${passwd2} \
    --command="put ${test_file}"
}

# Check that users from the same group can write to each other’s directories
# Usage: assert_group_write SHARE USER1 PASSWD1 USER2 PASSWD2
assert_group_write_dir() {
  local share="${1}"
  local user1="${2}"
  local passwd1="${3}"
  local user2="${4}"
  local passwd2="${5}"

  smbclient "//${sut_wins_name}/${share}" --user=${user1}%${passwd1} \
    --command="mkdir ${test_dir}; mkdir ${test_dir}/tst"
  run smbclient "//${sut_wins_name}/${share}" --user=${user2}%${passwd2} \
    --command="rmdir ${test_dir}/tst"
  [ -z "$(echo ${output} | grep NT_STATUS_ACCESS_DENIED)" ]
}

#}}}

#
# Low level tests
#
@test 'The command ‘smbclient’ should be available' {
  which smbclient
}

@test 'The Samba configuration file should be syntactically correct' {
  testparm --suppress-prompt /etc/samba/smb.conf
}

@test 'The Samba service should be running' {
  systemctl status smb.service
}

@test 'The Samba service should be enabled at boot' {
  systemctl is-enabled smb.service
}

@test 'The WinBind service should be running' {
  systemctl status nmb.service
}

@test 'The WinBind service should be enabled at boot' {
  systemctl is-enabled nmb.service
}

@test 'The SELinux status should be ‘enforcing’' {
  [ -n "$(sestatus) | grep 'enforcing'" ]
}

@test 'Samba traffic should pass through the firewall' {
  firewall-cmd --list-all | grep 'services.*samba\b'
}

#
# Acceptance tests
#

@test 'NetBIOS name resolution should work' {
  # Look up the Samba server’s NetBIOS name under the specified workgroup
  # The result should contain the IP followed by NetBIOS name
  nmblookup -U ${sut_ip} --workgroup ${workgroup} ${sut_wins_name} \
    | grep "^${sut_ip} ${sut_wins_name}"
}

@test "Check read access for share public" {
  #                  share  user          passwd
  assert_read_access public ${admin_user} ${admin_user}
  assert_read_access public lizae lizae
  assert_read_access public maartenm maartenm
  assert_read_access public maximdr maximdr
  assert_read_access public quintendc quintendc
  assert_read_access public stefaniel stefaniel
  assert_read_access public thomasb thomasb
  assert_no_read_access public
}

@test "Check read access for share technical" {
  assert_read_access technical ${admin_user} ${admin_user}
  assert_read_access technical lizae lizae
  assert_read_access technical maartenm maartenm
  assert_read_access technical maximdr maximdr
  assert_read_access technical quintendc quintendc
  assert_read_access technical stefaniel stefaniel
  assert_read_access technical thomasb thomasb
  assert_no_read_access technical
}

@test "Check read access for share financial" {
  assert_read_access    financial  ${admin_user} ${admin_user}
  assert_no_read_access financial  lizae lizae
  assert_no_read_access financial  maartenm maartenm
  assert_read_access    financial  maximdr maximdr
  assert_no_read_access financial  quintendc quintendc
  assert_no_read_access financial  stefaniel stefaniel
  assert_read_access    financial  thomasb thomasb
  assert_no_read_access financial
}

@test "Check read access for share management" {
  assert_read_access    management ${admin_user} ${admin_user}
  assert_read_access    management lizae lizae
  assert_no_read_access management maartenm maartenm
  assert_no_read_access management maximdr maximdr
  assert_read_access    management quintendc quintendc
  assert_no_read_access management stefaniel stefaniel
  assert_no_read_access management thomasb thomasb
  assert_no_read_access management
}

@test "Check write access for share public" {
  assert_write_access  public ${admin_user} ${admin_user}
  assert_write_access  public lizae lizae
  assert_write_access  public maartenm maartenm
  assert_write_access  public maximdr maximdr
  assert_write_access  public quintendc quintendc
  assert_write_access  public stefaniel stefaniel
  assert_write_access  public thomasb thomasb
}

@test "Check write access for share technical" {
  assert_write_access    technical  ${admin_user} ${admin_user}
  assert_no_write_access technical  lizae lizae
  assert_write_access    technical  maartenm maartenm
  assert_no_write_access technical  maximdr maximdr
  assert_no_write_access technical  quintendc quintendc
  assert_write_access    technical  stefaniel stefaniel
  assert_no_write_access technical  thomasb thomasb
}

@test "Check write access for share financial" {
  assert_write_access    financial  ${admin_user} ${admin_user}
  assert_no_write_access financial  lizae lizae
  assert_no_write_access financial  maartenm maartenm
  assert_write_access    financial  maximdr maximdr
  assert_no_write_access financial  quintendc quintendc
  assert_no_write_access financial  stefaniel stefaniel
  assert_write_access    financial  thomasb thomasb
}

@test "Check write access for share management" {
  assert_write_access    management ${admin_user} ${admin_user}
  assert_write_access    management lizae lizae
  assert_no_write_access management maartenm maartenm
  assert_no_write_access management maximdr maximdr
  assert_write_access    management quintendc quintendc
  assert_no_write_access management stefaniel stefaniel
  assert_no_write_access management thomasb thomasb
}

@test 'Users should have write access to their home directories' {
  #                   share     user      passwd
  assert_write_access lizae     lizae     lizae
  assert_write_access maartenm  maartenm  maartenm
  assert_write_access maximdr   maximdr   maximdr
  assert_write_access quintendc quintendc quintendc
  assert_write_access stefaniel stefaniel stefaniel
  assert_write_access thomasb   thomasb   thomasb
}

@test 'Group write access in share financial' {
  #                        share     user1   pwd1    user2   pwd2
  assert_group_write_file  financial maximdr maximdr thomasb thomasb
  assert_group_write_dir   financial maximdr maximdr thomasb thomasb
}

@test 'Group write access in share management' {
  #                        share      user1 pwd1  user2     pwd2
  assert_group_write_file  management lizae lizae quintendc quintendc
  assert_group_write_dir   management lizae lizae quintendc quintendc
}

@test 'Group write access in share technical' {
  #                       share      user1    pwd1     user2     pwd2
  assert_group_write_file technical  maartenm maartenm stefaniel stefaniel
  assert_group_write_dir  technical  maartenm maartenm stefaniel stefaniel
}

@test 'Group write access in share public' {
  # Remark that not all combinations are tested here!
  assert_group_write_file public lizae lizae thomasb thomasb
  assert_group_write_file public thomasb thomasb maartenm maartenm
  assert_group_write_file public maartenm maartenm quintendc quintendc
  assert_group_write_file public quintendc quintendc maximdr maximdr
  assert_group_write_file public maximdr maximdr stefaniel stefaniel
  assert_group_write_file public stefaniel stefaniel lizae lizae
}
