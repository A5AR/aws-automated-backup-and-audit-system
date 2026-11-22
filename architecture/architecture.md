
# System Architecture

The diagram below illustrates the network infrastructure and automated backup workflow.

```mermaid
flowchart TB
    Admin["Administrator"]

    subgraph VPC["Amazon VPC - 10.0.0.0/16"]
        subgraph Public["Public Subnet - 10.0.1.0/24"]
            Bastion["Bastion Host<br/>Public EC2"]
            IGW["Internet Gateway"]
        end

        subgraph Private["Private Subnet - 10.0.2.0/24"]
            App["Application Server<br/>Private EC2"]
            Generator["Data Generator<br/>systemd"]
            Backup["Backup Script<br/>cron every 10 minutes"]
        end

        Endpoint["S3 Gateway VPC Endpoint"]
    end

    S3[("Private Amazon S3 Bucket")]
    Lambda["AWS Lambda<br/>Backup Audit Logger"]
    Dynamo[("Amazon DynamoDB<br/>backup-log")]
    CW["Amazon CloudWatch Logs"]

    Admin -->|"SSH"| Bastion
    Bastion -->|"SSH"| App
    IGW --- Bastion

    App --> Generator
    Generator -->|"Writes application data"| Backup
    Backup -->|"Uploads backup archives"| Endpoint
    Endpoint --> S3

    S3 -->|"Object creation event"| Lambda
    Lambda -->|"PutItem"| Dynamo
    Lambda --> CW
```

## Backup Workflow

1. The data generator writes application data every 30 seconds.
2. Cron executes the backup script every 10 minutes.
3. The script compresses the application data and uploads the archive to S3.
4. The S3 Gateway VPC Endpoint provides private connectivity to S3.
5. S3 sends an object creation event to Lambda.
6. Lambda records the backup metadata in DynamoDB.
7. Lambda execution logs are captured in CloudWatch.

**Network note:** A NAT Gateway was used temporarily during setup to install software on the private server. It was deleted after installation. The S3 Gateway VPC Endpoint allows backups to continue without it.
