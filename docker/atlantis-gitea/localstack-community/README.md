# Localstack Community

**Pre-requirements**
- Create `localstack` AWS Profile

```text
:~ $ aws configure --profile localstack
AWS Access Key ID [None]: test
AWS Secret Access Key [None]: test
Default region name [None]: us-east-1
Default output format [None]: json
```

- (Optional) Create an alias
```bash
alias awslocal='aws --endpoint-url=http://localhost:4566 --profile localstack'
```

**Set up AWS resources for tofu/terraform**

Each time the localstack service restarts, we need to recreate the S3 bucket used to store the tf state


```bash
# Create s3 bucket
awslocal s3 mb s3://terraform-state-local

# Create dynamodb lock
awslocal dynamodb create-table \
    --table-name terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

We can find out the resources that localstack is managing by running the `audit_localstack.sh` script

## FAQ

1. **Do we need to map the port range `4510-4559`?**
- Yes, if we want to use RDS, OpenSearch EKS or other services that requires direct TCP connection 
- No, if we are only going to use S3, DynamoDB, SQS, Lambda, SNS