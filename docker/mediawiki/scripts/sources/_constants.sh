#!/usr/bin/env bash

# Set the backup directory path
BACKUP_DIR='/backups'
EXTENSION_DIR="/var/www/html/extensions"

# Set the backup source
BACKUP_SOURCE="/var/www/html/images"  # Set the source directory for the backup
BACKUP_DESTINATION="${BACKUP_SOURCE}" # Set the destination directory for the backup (same as source in this case)

# Set the backup file prefix
BACKUP_FILE_PREFIX='images' # Prefix for backup files containing data specifically from the database service, focusing on DBMS backups

# Set the backup file suffix
BACKUP_FILE_SUFFIX="imgs"

# Define a pattern to match the database backup file name and extract the full database name
DATA_BACKUP_PATTERN="^([^_]+_db)_.*_imgs.tar.zx$"
