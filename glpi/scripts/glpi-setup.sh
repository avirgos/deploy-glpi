#!/bin/bash

######################################################################
# Template
######################################################################
set -o errexit  # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset  # Exit if variable not set.
IFS=$'\n\t'     # Remove the initial space and instead use '\n'.

######################################################################
# Global variables
######################################################################
GLPI_VERSION="10.0.16"
PHP_VERSION="8.2"
GLPI_INSTALL_DIR="/var/www/glpi"
GLPI_VERSION_DIR=""${GLPI_INSTALL_DIR}"/version"

# update and install dependencies
apt-get update && apt-get install -y wget tar nginx php"${PHP_VERSION}" php"${PHP_VERSION}"-fpm php"${PHP_VERSION}"-mysql php"${PHP_VERSION}"-xml php"${PHP_VERSION}"-mbstring php"${PHP_VERSION}"-curl php"${PHP_VERSION}"-intl php"${PHP_VERSION}"-gd php"${PHP_VERSION}"-ldap php"${PHP_VERSION}"-phar php"${PHP_VERSION}"-bz2 php"${PHP_VERSION}"-zip

# php.ini
sed -i "s/^;session.cookie_secure =/session.cookie_secure = On/" /etc/php/"${PHP_VERSION}"/fpm/php.ini
sed -i "s/^session.cookie_httponly =/session.cookie_httponly = On/" /etc/php/"${PHP_VERSION}"/fpm/php.ini
sed -i "s/^session.cookie_samesite =/session.cookie_samesite = Lax/" /etc/php/"${PHP_VERSION}"/fpm/php.ini 

# first installation of GLPI
if [ -z "$(ls -A "${GLPI_INSTALL_DIR}")" ]
then
    wget https://github.com/glpi-project/glpi/releases/download/"${GLPI_VERSION}"/glpi-"${GLPI_VERSION}".tgz
    tar -xvf glpi-"${GLPI_VERSION}".tgz -C /var/www
# check for GLPI update
else
    # GLPI already configured
    if [ -f ""${GLPI_INSTALL_DIR}"/config/config_db.php" ]
    then
        # remove install.php
        if [ -f ""${GLPI_INSTALL_DIR}"/install/install.php" ]
        then
            rm ""${GLPI_INSTALL_DIR}"/install/install.php"
        fi
    fi
fi

# nginx
chown -R www-data:www-data "${GLPI_INSTALL_DIR}"
ln -s /etc/nginx/sites-available/glpi.conf /etc/nginx/sites-enabled/glpi.conf
rm /etc/nginx/sites-enabled/default
echo 'daemon off;' >> /etc/nginx/nginx.conf
    
# start services
service php"${PHP_VERSION}"-fpm start
nginx