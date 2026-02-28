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
BACKUPS_DIR="backups"
TIMESTAMP=$(date +"%Y-%m-%d")

MARIADB_BACKUP_FILE="db-backup-"${TIMESTAMP}".sql"
GLPI_INSTALL_DIR="/var/www/glpi"
GLPI_BACKUP_DIR="glpi-backup-"${TIMESTAMP}""

# Prepare backup directory
mkdir -p "${BACKUPS_DIR}"

######################################################################
# MariaDB backup
######################################################################
echo "Creating MariaDB backup..."

# Create MariaDB backup in Docker container
docker exec glpi-mariadb bash -c "mariadb-dump -u\"\$MARIADB_USER\" -p\"\$MARIADB_PASSWORD\" \"\$MARIADB_DATABASE\" > /tmp/"${MARIADB_BACKUP_FILE}""

# Copy MariaDB backup to 'localhost'
docker cp glpi-mariadb:/tmp/"${MARIADB_BACKUP_FILE}" .

# Remove MariaDB backup in Docker container
docker exec glpi-mariadb bash -c "rm /tmp/"${MARIADB_BACKUP_FILE}""

# Store MariaDB backup to backups directory
mv "${MARIADB_BACKUP_FILE}" "${BACKUPS_DIR}"

echo "MariaDB backup completed successfully: "${BACKUPS_DIR}"/"${MARIADB_BACKUP_FILE}""

######################################################################
# GLPI data backup
######################################################################
if [ ! -d "${BACKUPS_DIR}"/"${GLPI_BACKUP_DIR}" ]
then
    echo "Creating GLPI data backup..."

    # Create GLPI data backup in Docker container
    docker exec glpi bash -c "mkdir -p /tmp/"${GLPI_BACKUP_DIR}"/config"
    docker exec glpi bash -c "mkdir -p /tmp/"${GLPI_BACKUP_DIR}"/files"
    docker exec glpi bash -c "mkdir -p /tmp/"${GLPI_BACKUP_DIR}"/marketplace"
    docker exec glpi bash -c "mkdir -p /tmp/"${GLPI_BACKUP_DIR}"/plugins"

    docker exec glpi bash -c "cp -R "${GLPI_INSTALL_DIR}/config" /tmp/"${GLPI_BACKUP_DIR}""
    docker exec glpi bash -c "cp -R "${GLPI_INSTALL_DIR}/files" /tmp/"${GLPI_BACKUP_DIR}""
    docker exec glpi bash -c "cp -R "${GLPI_INSTALL_DIR}/marketplace" /tmp/"${GLPI_BACKUP_DIR}""
    docker exec glpi bash -c "cp -R "${GLPI_INSTALL_DIR}/plugins" /tmp/"${GLPI_BACKUP_DIR}""
  
    # Copy GLPI data backup to 'localhost'
    docker cp glpi:/tmp/"${GLPI_BACKUP_DIR}" .

    # Remove GLPI data backup in Docker container
    docker exec glpi bash -c "rm -r /tmp/"${GLPI_BACKUP_DIR}""

    # Move GLPI data backup to backups directory
    mv "${GLPI_BACKUP_DIR}" "${BACKUPS_DIR}"

    echo "GLPI data backup completed successfully: "${BACKUPS_DIR}"/"${GLPI_BACKUP_DIR}""
else
    echo "GLPI backup for today already exists, skipping..."
fi
