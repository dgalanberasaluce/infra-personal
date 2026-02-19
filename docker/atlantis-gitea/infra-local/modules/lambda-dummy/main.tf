variable "target_bucket_name" {
  description = "Bucket name used by the lambda"
  type        = string
}

data "archive_file" "dummy" {
  type        = "zip"
  output_path = "${path.module}/function.zip"
  source {
    content  = "exports.handler = async (event) => { console.log('Hello LocalStack'); };"
    filename = "index.js"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_lambda_function" "test_lambda" {
  filename      = data.archive_file.dummy.output_path
  function_name = "sysadmin-processor"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      BUCKET_A_PROCESAR = var.target_bucket_name
    }
  }
}