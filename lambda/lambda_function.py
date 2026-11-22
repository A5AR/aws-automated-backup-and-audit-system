
import json
import boto3
import urllib.parse
from datetime import datetime, timezone

# Initialise DynamoDB resource
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("backup-log")


def lambda_handler(event, context):
    for record in event.get("Records", []):

        # Process only S3 events
        if record.get("eventSource") != "aws:s3":
            continue

        # Extract bucket name and uploaded object key
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(
            record["s3"]["object"]["key"]
        )

        # Get the event timestamp
        event_time = record.get(
            "eventTime",
            datetime.now(timezone.utc).isoformat()
        )

        # Use the backup filename as the audit record ID
        backup_id = key.split("/")[-1]

        # Store backup metadata in DynamoDB
        table.put_item(
            Item={
                "backup_id": backup_id,
                "bucket": bucket,
                "object_key": key,
                "event_time": event_time
            }
        )

    return {
        "statusCode": 200,
        "body": json.dumps("Backup audit records processed")
    }
