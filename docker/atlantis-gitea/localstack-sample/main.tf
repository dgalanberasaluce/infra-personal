resource "aws_s3_bucket" "this" {
  bucket = "my-bucket"
}

resource "aws_dynamodb_table" "this" {
  name           = "LocalUsers"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }
}

resource "aws_sqs_queue" "this" {
  name = "my-queue"
}