#!/bin/bash
# backup.sh - Create a backup of project folder

# Set directories
PROJECT_DIR="$HOME/my_project"
BACKUP_DIR="$HOME/backups"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create backup archive
BACKUP_FILE="$BACKUP_DIR/my_project_backup_$TIMESTAMP.tar.gz"
echo "Creating backup at $BACKUP_FILE..."
tar -czf "$BACKUP_FILE" -C "$PROJECT_DIR" .

echo "Backup completed successfully!"
