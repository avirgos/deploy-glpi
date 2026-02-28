#!/bin/bash

######################################################################
# Template
######################################################################
set -o errexit  # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset  # Exit if variable not set.
IFS=$'\n\t'     # Remove the initial space and instead use '\n'.

######################################################################
# Global variables (internal)
######################################################################
GLPI_VERSION="10.0.16"
PHP_VERSION="8.2"
GLPI_INSTALL_DIR="/var/www/glpi"

# Backup used for GLPI update
GLPI_BACKUP_TIMESTAMP="2024-11-18"
GLPI_BACKUP_DIR="/var/www/glpi-backup-"${GLPI_BACKUP_TIMESTAMP}""

###############################################################################
# Install system dependencies
###############################################################################
apt-get update && apt-get install -y 
    wget \
    tar \ 
    nginx \
    php"${PHP_VERSION}" \ 
    php"${PHP_VERSION}"-fpm \ 
    php"${PHP_VERSION}"-mysql \ 
    php"${PHP_VERSION}"-xml \ 
    php"${PHP_VERSION}"-mbstring \ 
    php"${PHP_VERSION}"-curl \ 
    php"${PHP_VERSION}"-intl \
    php"${PHP_VERSION}"-gd \
    php"${PHP_VERSION}"-ldap \
    php"${PHP_VERSION}"-phar \
    php"${PHP_VERSION}"-bz2 \
    php"${PHP_VERSION}"-zip

###############################################################################
# Configure PHP ('php.ini')
###############################################################################
sed -i "s/^;session.cookie_secure =/session.cookie_secure = On/" /etc/php/"${PHP_VERSION}"/fpm/php.ini
sed -i "s/^session.cookie_httponly =/session.cookie_httponly = On/" /etc/php/"${PHP_VERSION}"/fpm/php.ini
sed -i "s/^session.cookie_samesite =/session.cookie_samesite = Lax/" /etc/php/"${PHP_VERSION}"/fpm/php.ini 

function update_glpi() {
    # Purge previous GLPI
    cd "${GLPI_INSTALL_DIR}"
    rm -rf *

    # Restore GLPI backup directories
    cd "${GLPI_BACKUP_DIR}"
    cp -r files "${GLPI_INSTALL_DIR}"
    cp -r plugins "${GLPI_INSTALL_DIR}"
    cp -r config "${GLPI_INSTALL_DIR}"
    cp -r marketplace "${GLPI_INSTALL_DIR}"

    # Install new GLPI version
    cd /tmp
    wget https://github.com/glpi-project/glpi/releases/download/"${GLPI_VERSION}"/glpi-"${GLPI_VERSION}".tgz
    tar -xvf glpi-"${GLPI_VERSION}".tgz -C /tmp
    cd glpi
    rm -rf config files marketplace plugins
    cp -R * "${GLPI_INSTALL_DIR}"

    # Update MariaDB database
    cd "${GLPI_INSTALL_DIR}"
    (
        sleep 30
        echo "Yes"
	    sleep 30
	    echo "No"
    ) | php bin/console db:update
}
###############################################################################
# GLPI installation or update
###############################################################################
# First installation of GLPI
if [ -z "$(ls -A "${GLPI_INSTALL_DIR}")" ]
then
    wget https://github.com/glpi-project/glpi/releases/download/"${GLPI_VERSION}"/glpi-"${GLPI_VERSION}".tgz
    tar -xvf glpi-"${GLPI_VERSION}".tgz -C /var/www
# Check for GLPI update
else
    # Check if GLPI directory has exactly "4" subdirectories and 'config_db.php' exists
    if [ "$(find "${GLPI_BACKUP_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)" -eq 4 ] && [ -f ""${GLPI_INSTALL_DIR}"/config/config_db.php" ]
    then
        update_glpi
    fi

    # Remove 'install.php' if it exists
    if [ -f ""${GLPI_INSTALL_DIR}"/install/install.php" ]
    then
        rm ""${GLPI_INSTALL_DIR}"/install/install.php"
    fi
fi

###############################################################################
# Nginx configuration
###############################################################################
chown -R www-data:www-data "${GLPI_INSTALL_DIR}"
ln -s /etc/nginx/sites-available/glpi.conf /etc/nginx/sites-enabled/glpi.conf
rm /etc/nginx/sites-enabled/default
echo 'daemon off;' >> /etc/nginx/nginx.conf
    
###############################################################################
# Start services
###############################################################################
service php"${PHP_VERSION}"-fpm start
nginx