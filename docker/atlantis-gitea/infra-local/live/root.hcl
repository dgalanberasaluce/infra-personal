generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  
  # avoid dns errors
  s3_use_path_style           = true

  # La configuración centralizada de LocalStack
  endpoints {
    apigateway     = "http://host.docker.internal:4566"
    cloudformation = "http://host.docker.internal:4566"
    cloudwatch     = "http://host.docker.internal:4566"
    dynamodb       = "http://host.docker.internal:4566"
    ec2            = "http://host.docker.internal:4566"
    es             = "http://host.docker.internal:4566"
    elasticache    = "http://host.docker.internal:4566"
    firehose       = "http://host.docker.internal:4566"
    iam            = "http://host.docker.internal:4566"
    kinesis        = "http://host.docker.internal:4566"
    lambda         = "http://host.docker.internal:4566"
    rds            = "http://host.docker.internal:4566"
    redshift       = "http://host.docker.internal:4566"
    route53        = "http://host.docker.internal:4566"
    s3             = "http://host.docker.internal:4566"
    secretsmanager = "http://host.docker.internal:4566"
    ses            = "http://host.docker.internal:4566"
    sns            = "http://host.docker.internal:4566"
    sqs            = "http://host.docker.internal:4566"
    ssm            = "http://host.docker.internal:4566"
    stepfunctions  = "http://host.docker.internal:4566"
    sts            = "http://host.docker.internal:4566"
  }
}
EOF
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "terraform-state-local"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    
    endpoint                    = "http://host.docker.internal:4566"
    dynamodb_endpoint           = "http://host.docker.internal:4566"
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true # avoid dns errors
    
    skip_requesting_account_id  = true

    # It solves "Error: No valid credential sources found"
    access_key = "test"
    secret_key = "test"
  }
}
