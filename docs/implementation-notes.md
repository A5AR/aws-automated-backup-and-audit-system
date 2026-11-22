# Implementation Notes

## 1. Network Infrastructure

The project was deployed within a custom Amazon VPC using the CIDR block `10.0.0.0/16`.

Two subnets were created:

- **Public subnet:** `10.0.1.0/24`, hosting the bastion server.
- **Private subnet:** `10.0.2.0/24`, hosting the application server.

The bastion host provides controlled SSH access to the private application server. The application server does not have a public IP address, and its security group permits SSH access only from the bastion host's security group.

## 2. Private S3 Connectivity

A NAT Gateway was temporarily deployed to provide internet connectivity while installing the required software on the private application server.

After installation, the NAT Gateway was deleted to reduce unnecessary costs.

An Amazon S3 Gateway VPC Endpoint was associated with the private subnet's route table. This allowed the application server to continue uploading backups to S3 without requiring a NAT Gateway or general internet access.

## 3. IAM and Access Control

An IAM role was created and attached to the application server.

The role grants permission to perform `s3:PutObject` operations only within the designated `backups/` prefix of the S3 bucket.

This follows the principle of least privilege. The application server can upload backup files but cannot delete them or list the bucket contents.

No long-term AWS access keys were stored on the server.

## 4. Backup Automation

Two scripts were implemented:

- `data-generator.sh` continuously generates timestamped application data.
- `backup.sh` compresses the application data and uploads the resulting archive to S3.

A systemd service manages the data generator, while cron schedules the backup script to run every 10 minutes.

The backup script records successful and failed operations in `/var/log/backup.log` and removes local archives only after successful uploads.

## 5. Serverless Audit Logging

An AWS Lambda function was configured to respond to S3 object creation events under the `backups/` prefix.

The function extracts the uploaded object's metadata and stores it in the DynamoDB `backup-log` table.

CloudWatch Logs was used to inspect Lambda execution activity.

## 6. Testing and Troubleshooting

The implementation was validated through several tests:

- SSH connectivity was established through the bastion host.
- The application data generator was confirmed to run as a systemd service.
- Automated backup uploads to S3 were verified.
- An attempted S3 deletion using the EC2 role returned Access Denied, confirming the restricted permissions.
- External internet connectivity failed after NAT Gateway removal, while S3 uploads continued successfully through the Gateway VPC Endpoint.
- S3 object creation successfully triggered Lambda and generated corresponding DynamoDB audit records.

## 7. Cost Considerations

A temporary NAT Gateway was used only during software installation and subsequently removed. An AWS Budget alert was also configured to monitor project spending.

The project demonstrates how private connectivity to AWS services can reduce dependence on continuously running NAT infrastructure.

