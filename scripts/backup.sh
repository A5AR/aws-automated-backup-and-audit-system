
#!/bin/bash

set -euo pipefail

# Configuration
BACKUP_DIR="/var/app"
LOG_FILE="/var/log/backup.log"
S3_BUCKET="s3://YOUR_BUCKET_NAME/backups"

# Generate backup filename using the current date and time
TIMESTAMP=$(date +"%Y-%m-%d-%H%M")
BACKUP_FILE="backup-${TIMESTAMP}.tar.gz"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILE}"

# Function to record backup activity
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Create a compressed archive of application data
if tar -czf "$BACKUP_PATH" -C /var/app data; then

    # Upload the archive to Amazon S3
    if aws s3 cp "$BACKUP_PATH" "$S3_BUCKET/$BACKUP_FILE"; then
        log_message "SUCCESS: Uploaded $BACKUP_FILE to S3"

        # Remove local archive after successful upload
        rm "$BACKUP_PATH"
    else
        log_message "FAILURE: Upload failed for $BACKUP_FILE"
        exit 1
    fi

else
    log_message "FAILURE: Archive creation failed for $BACKUP_FILE"
    exit 1
fi
