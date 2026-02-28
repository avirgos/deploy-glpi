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
GLPI_MARIADB_CONTAINER="glpi-mariadb"
GLPI_CONTAINER="glpi"
MARIADB_ROOT_PASSWORD=$(grep 'MARIADB_ROOT_PASSWORD' secrets.env | cut -d'=' -f2)
GLPI_USER=$(grep 'MARIADB_USER' secrets.env | cut -d'=' -f2)
GLPI_DB=$(grep 'MARIADB_DATABASE' secrets.env | cut -d'=' -f2)

######################################################################
# Configure privileges for 'GLPI_USER'
######################################################################
docker exec -i "${GLPI_MARIADB_CONTAINER}" mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" <<EOF
USE "${GLPI_DB}";
GRANT SELECT ON mysql.time_zone_name TO '${GLPI_USER}'@'%';
FLUSH PRIVILEGES;
exit
EOF

# Activate timezones
docker exec -i "${GLPI_CONTAINER}" bash -c "cd /var/www/glpi && php bin/console database:enable_timezones"