#!/bin/bash

echo "--- Checking LocalStack Resources ---"

echo -e "\n S3 Buckets:"
aws --endpoint-url=http://localhost:4566 --profile localstack s3 ls

echo -e "\n DynamoDB Tables:"
aws --endpoint-url=http://localhost:4566 --profile localstack dynamodb list-tables --query "TableNames[]" --output text

echo -e "\n Lambda Functions:"
aws --endpoint-url=http://localhost:4566 --profile localstack lambda list-functions --query "Functions[].FunctionName" --output text

echo -e "\n SQS Queues:"
aws --endpoint-url=http://localhost:4566 --profile localstack sqs list-queues --query "QueueUrls[]" --output text

echo -e "\n SNS Topics:"
aws --endpoint-url=http://localhost:4566 --profile localstack sns list-topics --query "Topics[].TopicArn" --output text

echo -e "\n EC2 Instances:"
aws --endpoint-url=http://localhost:4566 --profile localstack ec2 describe-instances --query "Reservations[].Instances[].InstanceId" --output text
