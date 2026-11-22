# Automated AWS Backup and Audit Logging System

## Project Overview

This project implements an automated backup and audit logging system on Amazon Web Services (AWS).

The system runs a private application server on Amazon EC2, periodically generates application data, archives the data, and uploads the backup files to a private Amazon S3 bucket. AWS Lambda is triggered whenever a new backup is uploaded and records the backup metadata in Amazon DynamoDB.

The solution demonstrates cloud infrastructure deployment, Linux administration, Bash scripting, IAM-based access control, automated scheduling, serverless computing, and secure communication with AWS services.

## Architecture

The infrastructure consists of the following components:

- **Amazon VPC:** Provides an isolated network environment for the application.
- **Public subnet:** Hosts a bastion server used as a secure entry point.
- **Private subnet:** Hosts the application server without a public IP address.
- **Internet Gateway:** Provides internet connectivity to the public subnet.
- **NAT Gateway:** Used temporarily to install required software on the private server. It was removed after setup.
- **Amazon S3 Gateway VPC Endpoint:** Allows the private application server to communicate with S3 without requiring internet access or a NAT Gateway.
- **Amazon EC2:** Hosts the application and backup processes.
- **AWS IAM:** Provides role-based permissions for secure access to AWS services.
- **Amazon S3:** Stores the backup archives in a private bucket.
- **AWS Lambda:** Processes S3 object creation events.
- **Amazon DynamoDB:** Stores backup metadata for auditing.
- **Amazon CloudWatch:** Captures Lambda execution logs.
- **AWS Budgets:** Provides cost monitoring and budget alerts.

## How It Works

1. The application server runs a systemd-managed service that generates timestamped application data every 30 seconds.
2. A Bash backup script runs automatically every 10 minutes through cron.
3. The script archives the application data into a compressed `.tar.gz` file.
4. The backup archive is uploaded to a private S3 bucket using the AWS CLI.
5. The EC2 instance uses an attached IAM role to authenticate with AWS. No long-term AWS access keys are stored on the server.
6. The S3 upload triggers an AWS Lambda function.
7. Lambda extracts the backup metadata and writes an audit record to DynamoDB.
8. Lambda execution activity is available in CloudWatch Logs.

## Security Implementation

Security was considered throughout the implementation:

- The application server is deployed in a private subnet and has no public IP address.
- SSH access to the application server is restricted to the bastion server's security group.
- SSH access to the bastion server is restricted to the administrator's IP address.
- The S3 bucket is private, with S3 Block Public Access enabled.
- The EC2 IAM role has permission to upload objects only to the designated `backups/` prefix.
- The application server cannot delete uploaded backups using its assigned IAM permissions.
- The application server accesses S3 through a Gateway VPC Endpoint after the NAT Gateway is removed.

## Technologies and AWS Services

- Amazon Web Services (AWS)
- Amazon EC2
- Amazon VPC
- Amazon S3
- AWS IAM
- AWS Lambda
- Amazon DynamoDB
- Amazon CloudWatch
- AWS Budgets
- Linux (Ubuntu)
- Bash scripting
- systemd
- cron
- AWS CLI
- Python

## Repository Structure

```text
.
├── README.md
├── architecture/
│   └── architecture-diagram.png
├── scripts/
│   ├── backup.sh
│   └── data-generator.sh
├── lambda/
│   └── lambda_function.py
├── systemd/
│   └── data-generator.service
└── docs/
    ├── screenshots/
    └── implementation-notes.md
```

## Testing and Validation

The following tests were performed:

- Verified SSH access through the bastion server to the private application server.
- Confirmed that the data generator service runs and produces timestamped application logs.
- Verified that the backup script creates compressed archives and uploads them to S3.
- Confirmed that the EC2 IAM role permits uploads but denies deletion attempts.
- Verified that S3 uploads continue to work through the Gateway VPC Endpoint after the NAT Gateway is removed.
- Confirmed that S3 object creation events trigger the Lambda function.
- Verified that backup metadata is recorded in DynamoDB.
- Reviewed Lambda execution logs in CloudWatch.
- Configured an AWS Budget alert to monitor project costs.

## Challenges and Lessons Learned

Working on this project provided practical experience with private AWS networking, IAM permissions, Linux service management, and serverless event-driven architectures.

One important lesson was understanding the difference between internet connectivity and private AWS service connectivity. After removing the NAT Gateway, the application server could no longer reach external websites, but it could still upload backups to S3 through the Gateway VPC Endpoint.

I also gained experience troubleshooting SSH access, configuring IAM policies with least privilege, automating Linux tasks, and connecting S3 events to Lambda and DynamoDB.

## Possible Improvements

Some improvements that could be introduced in a production environment include:

- Enabling S3 bucket versioning.
- Configuring S3 lifecycle policies for backup retention.
- Introducing backup integrity checks.
- Adding alerts for failed backup operations.
- Implementing more comprehensive monitoring and reporting.
- Using infrastructure as code with Terraform or AWS CloudFormation.
- Introducing automated deployment and testing pipelines.

## Project Status

**Implementation completed and tested.**

This project was completed as part of the AltSchool Africa Cloud Engineering programme.

