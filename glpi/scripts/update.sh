#!/bin/bash

######################################################################
# Template
######################################################################
set -o errexit  # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset  # Exit if variable not set.
IFS=$'\n\t'     # Remove the initial space and instead use '\n'.

######################################################################
# Global variables (user‑modifiable)
######################################################################
NEW_GLPI_VERSION="10.0.17"
GLPI_BACKUP_TIMESTAMP="2024-11-18" 		# format YYYY-MM-DD"

######################################################################
# Global variables (internal)
######################################################################
GLPI_BACKUP_VOLUME="- ./backups/glpi-backup-"${GLPI_BACKUP_TIMESTAMP}"/:/var/www/glpi-backup-"${GLPI_BACKUP_TIMESTAMP}""
GLPI_VOLUME="- glpi-data:/var/www/glpi"
GLPI_SETUP_SCRIPT="./scripts/glpi-setup.sh"

# Backup MariaDB + GLPI data
./scripts/backup.sh

# Backup 'docker-compose.yml'
cp docker-compose.yml docker-compose.yml.bak

######################################################################
# Add GLPI backup volume below the existing GLPI volume
######################################################################
{
    while IFS= read -r line
    do
        echo "${line}" >> docker-compose.yml.tmp
        if [[ "${line}" == *"${GLPI_VOLUME}"* ]]
        then
            echo "      "${GLPI_BACKUP_VOLUME}"" >> docker-compose.yml.tmp
        fi
    done < docker-compose.yml
} && mv docker-compose.yml.tmp docker-compose.yml

######################################################################
# Modify 'GLPI_VERSION' and 'TIMESTAMP' variables in 'scripts/glpi-setup.sh'
######################################################################
sed -i "s|^GLPI_VERSION=.*|GLPI_VERSION=\"${NEW_GLPI_VERSION}\"|" "${GLPI_SETUP_SCRIPT}"
sed -i "s|^GLPI_BACKUP_TIMESTAMP=.*|GLPI_BACKUP_TIMESTAMP=\"${GLPI_BACKUP_TIMESTAMP}\"|" "${GLPI_SETUP_SCRIPT}"

# Run 'deploy.sh'
./deploy.sh

# Restore original 'docker-compose.yml'
mv docker-compose.yml.bak docker-compose.yml
