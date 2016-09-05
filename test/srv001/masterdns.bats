#! /usr/bin/env bats
#
# test/srv001/masterdns.bats
# Acceptance test for the DNS server for linuxlab.lan
#

sut_ip=192.168.15.2
domain=linuxlab.lan

#{{{ Helper functions

# Usage: assert_forward_lookup NAME IP
# Exits with status 0 if NAME.DOMAIN resolves to IP, a nonzero
# status otherwise
assert_forward_lookup() {
  local name="$1"
  local ip="$2"

  [ "$ip" = "$(dig @${sut_ip} ${name}.${domain} +short)" ]
}

# Usage: assert_reverse_lookup NAME IP
# Exits with status 0 if a reverse lookup on IP resolves to NAME,
# a nonzero status otherwise
assert_reverse_lookup() {
  local name="$1"
  local ip="$2"

  [ "${name}.${domain}." = "$(dig @${sut_ip} -x ${ip} +short)" ]
}

# Usage: assert_alias_lookup ALIAS NAME IP
# Exits with status 0 if a forward lookup on NAME resolves to the
# host name NAME.DOMAIN and to IP, a nonzero status otherwise
assert_alias_lookup() {
  local alias="$1"
  local name="$2"
  local ip="$3"
  local result="$(dig @${sut_ip} ${alias}.${domain} +short)"

  echo ${result} | grep "${name}\.${domain}\."
  echo ${result} | grep "${ip}"
}

# Usage: assert_ns_lookup NS_NAME...
# Exits with status 0 if all specified host names occur in the list of
# name servers for the domain.
assert_ns_lookup() {
  local result="$(dig @${sut_ip} ${domain} NS +short)"

  [ -n "${result}" ] # the list of name servers should not be empty
  while (( "$#" )); do
    echo "${result}" | grep "$1\.${domain}\."
    shift
  done
}

# Usage: assert_mx_lookup PREF1 NAME1 PREF2 NAME2...
#   e.g. assert_mx_lookup 10 mailsrv1 20 mailsrv2
# Exits with status 0 if all specified host names occur in the list of
# mail servers for the domain.
assert_mx_lookup() {
  local result="$(dig @${sut_ip} ${domain} MX +short)"

  [ -n "${result}" ] # the list of name servers should not be empty
  while (( "$#" )); do
    echo "${result}" | grep "$1 $2\.${domain}\."
    shift
    shift
  done
}

#}}}

@test 'The `dig` command should be installed' {
  which dig
}

@test 'The main config file should be syntactically correct' {
  named-checkconf /etc/named.conf
}

@test 'The forward zone file should be syntactically correct' {
  # It is assumed that the name of the zone file is the name of the zone
  # itself (without extra extension)
  named-checkzone ${domain} /var/named/${domain}
}

@test 'The reverse zone files should be syntactically correct' {
  # It is assumed that the name of the zone file is the name of the zone
  # itself (without extra extension)
  for zone_file in /var/named/*.in-addr.arpa; do
    reverse_zone=${zone_file##*/}
    named-checkzone ${reverse_zone} ${zone_file}
  done
}

@test 'The service should be running' {
  systemctl status named
}

@test 'Forward lookups' {
  #                     host name  IP
  assert_forward_lookup srv001     192.168.15.2
  assert_forward_lookup srv002     192.168.15.3
  assert_forward_lookup srv003     192.168.15.4
  assert_forward_lookup srv010     192.168.15.10
  assert_forward_lookup srv011     192.168.15.11
  assert_forward_lookup srv012     192.168.15.12
}

@test 'Reverse lookups' {
  #                     host name  IP
  assert_reverse_lookup srv001     192.168.15.2
  assert_reverse_lookup srv002     192.168.15.3
  assert_reverse_lookup srv003     192.168.15.4
  assert_reverse_lookup srv010     192.168.15.10
  assert_reverse_lookup srv011     192.168.15.11
  assert_reverse_lookup srv012     192.168.15.12
}

@test 'Alias lookups' {
  #                   alias      hostname  IP
  assert_alias_lookup ns1        srv001     192.168.15.2
  assert_alias_lookup ns2        srv002     192.168.15.3
  assert_alias_lookup mail       srv003     192.168.15.4
  assert_alias_lookup www        srv010     192.168.15.10
  assert_alias_lookup file       srv011     192.168.15.11
  assert_alias_lookup dhcp       srv012     192.168.15.12
}

@test 'NS record lookup' {
  assert_ns_lookup srv001 srv002
}

@test 'Mail server lookup' {
  assert_mx_lookup 10 srv003
}
