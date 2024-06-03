#!/bin/bash

# Set variables
file_name=$(date +%Y%m%d_%H%M%S)
directory_to_save="/path/SQL_Backup"
webhook_url="YOUR_DISCORD_WEBHOOK_URL"
cockroach_user="root"  # Assuming using the root user
cockroach_host="localhost"  # Assuming CockroachDB is running on localhost
cockroach_port="26257"  # Default CockroachDB port
database_name="YOUR_DATABASE_NAME"

# Ensure the backup directory exists
mkdir -p "$directory_to_save"

# Backup CockroachDB database
echo "Starting CockroachDB Backup..."
cockroach dump "$database_name" --insecure --host="$cockroach_host" --port="$cockroach_port" --user="$cockroach_user" > "$directory_to_save/$file_name.sql"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "CockroachDB Backup completed successfully."
    
    # Send notification via Discord webhook
    # Replace 'discord.sh' with the script you use for Discord webhook
    bash discord.sh --webhook-url "$webhook_url" --file "$directory_to_save/$file_name.sql"
    
    # Clean up CockroachDB backup file
    rm -f "$directory_to_save/$file_name.sql"
    
    echo "Cleanup completed."
else
    echo "CockroachDB Backup failed."
fi