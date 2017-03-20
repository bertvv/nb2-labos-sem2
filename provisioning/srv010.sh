#! /usr/bin/bash
#
# Provisioning script for srv010

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

# Database configuration
readonly mariadb_root_password=fogMeHud8
readonly wordpress_database=wp_db
readonly wordpress_user=wp_user
readonly wordpress_password=CorkIgWac

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
  httpd \
  mariadb \
  mariadb-server \
  mod_ssl \
  php \
  php-mysql \
  wordpress

info "Enabling services"

systemctl start httpd
systemctl enable httpd
systemctl start mariadb
systemctl enable mariadb

info "Configuring firewall"

systemctl start firewalld
systemctl enable firewalld

firewall-cmd --add-interface=enp0s8 --permanent
firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=https --permanent

systemctl restart firewalld

info "Set MariaDB root password"

if mysqladmin -u root status > /dev/null 2>&1; then
  # if the previous command succeeds, the root password was not set
  mysqladmin password "${mariadb_root_password}" > /dev/null 2>&1
  info "ok"
else
  info "password already set."
fi

info "Creating database"

mysql --user=root --password="${mariadb_root_password}" mysql << _EOF_
CREATE DATABASE IF NOT EXISTS ${wordpress_database};
GRANT ALL ON ${wordpress_database}.* TO '${wordpress_user}'@'localhost' identified by '${wordpress_password}';
DELETE FROM user WHERE user='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

info "Configuring server certificates"

cp "${PROVISIONING_FILES}/${HOSTNAME}.key" /etc/pki/tls/private
cp "${PROVISIONING_FILES}/${HOSTNAME}.crt" /etc/pki/tls/certs

cp "${PROVISIONING_FILES}/ssl.conf" /etc/httpd/conf.d/ssl.conf

info "Configuring Wordpress"

cp "${PROVISIONING_FILES}/wordpress.conf" /etc/httpd/conf.d/
cp "${PROVISIONING_FILES}/wp-config.php" /etc/wordpress/
systemctl restart httpd.service



