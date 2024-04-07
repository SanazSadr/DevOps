#!/bin/bash

# Set variables
file_name=$(date +%Y%m%d_%H%M%S)
password=""
database_name=""
directory_to_save="/path/SQL_Backup"
logstash_host="logstash.example.com"
logstash_port="5044"

# Ensure the backup directory exists
mkdir -p "$directory_to_save"

# Backup SQL database
echo "Starting SQL Backup..."
mysqldump -u usr --password="$password" "$database_name" > "$directory_to_save/$file_name.sql"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "SQL Backup completed successfully."
    
    # Send notification via Logstash
    echo "{\"message\": \"SQL Backup completed successfully\", \"file_name\": \"$file_name\", \"status\": \"success\"}" | nc "$logstash_host" "$logstash_port"
    
    # Clean up SQL backup file
    rm -f "$directory_to_save/$file_name.sql"
    
    echo "Cleanup completed."
else
    echo "SQL Backup failed."
    # Send notification via Logstash
    echo "{\"message\": \"SQL Backup failed\", \"file_name\": \"$file_name\", \"status\": \"failed\"}" | nc "$logstash_host" "$logstash_port"
fi