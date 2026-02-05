output "s3_bucket_name" {
  description = "The name of the s3 bucket"
  value       = aws_s3_bucket.b.id
}

output "dynamo_table_name" {
  description = "The name of the dynamodb table"
  value       = aws_dynamodb_table.t.name
}