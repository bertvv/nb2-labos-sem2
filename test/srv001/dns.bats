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

  echo "expected: ${name}"
  echo "        : ${ip}"
  echo "result  : ${result}"

  echo ${result} | grep "${name}"
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
  dnsmasq --test --conf-file=/etc/dnsmasq.conf
}

@test 'The service should be running' {
  systemctl status dnsmasq
}

@test 'Forward lookups' {
  #                     host name  IP
  assert_forward_lookup srv001     192.168.15.2
  assert_forward_lookup srv002     192.168.15.3
  assert_forward_lookup srv010     192.168.15.10
  assert_forward_lookup srv011     192.168.15.11
}

@test 'Reverse lookups' {
  #                     host name  IP
  assert_reverse_lookup srv001     192.168.15.2
  assert_reverse_lookup srv002     192.168.15.3
  assert_reverse_lookup srv010     192.168.15.10
  assert_reverse_lookup srv011     192.168.15.11
}

@test 'Alias lookups' {
  #                   alias      hostname  IP
  assert_alias_lookup ns         srv001     192.168.15.2
  assert_alias_lookup dhcp       srv002     192.168.15.3
  assert_alias_lookup www        srv010     192.168.15.10
  assert_alias_lookup file       srv011     192.168.15.11
}
