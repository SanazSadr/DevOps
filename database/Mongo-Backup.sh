#!/bin/bash

# Set variables
file_name=$(date +%Y%m%d_%H%M%S)
password=""
database_name=""
directory_to_save="/path/MongoDB_Backup"
webhook_url="YOUR_DISCORD_WEBHOOK_URL"

# Ensure the backup directory exists
mkdir -p "$directory_to_save"

# Backup MongoDB database
echo "Starting MongoDB Backup..."
mongodump --username usr --password "$password" --authenticationDatabase admin --db "$database_name" --out "$directory_to_save/$file_name"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "MongoDB Backup completed successfully."

    # Send notification via Discord webhook
    bash discord.sh --webhook-url "$webhook_url" --file "$directory_to_save/$file_name"

    # Clean up MongoDB backup directory
    rm -rf "$directory_to_save/$file_name"

    echo "Cleanup completed."
else
    echo "MongoDB Backup failed."
fi