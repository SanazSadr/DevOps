#!/bin/bash

# Set variables
file_name=$(date +%Y%m%d_%H%M%S)
directory_to_save="/path/ClickHouse_Backup"
webhook_url="YOUR_DISCORD_WEBHOOK_URL"

# Ensure the backup directory exists
mkdir -p "$directory_to_save"

# Backup ClickHouse database
echo "Starting ClickHouse Backup..."
clickhouse-backup create "$directory_to_save/$file_name"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "ClickHouse Backup completed successfully."
    
    # Send notification via Discord webhook
    bash discord.sh --webhook-url "$webhook_url" --file "$directory_to_save/$file_name"
    
    # Clean up ClickHouse backup files (optional)
    # rm -rf "$directory_to_save/$file_name"
    
    echo "Cleanup completed."
else
    echo "ClickHouse Backup failed."
fi