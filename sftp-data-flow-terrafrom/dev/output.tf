output "main_bucket_arn" {
  value = module.transfer_bucket.s3_bucket_arn
}

output "main_s3_bucket" {
  description = "S3 bucket destination for aws transfer family"
  value       = module.transfer_bucket.s3_bucket_id
}

output "lambda_function_arn" {
  value = aws_lambda_function.alert_lambda_function.arn
}

output "lambda_log_group_arn" {
  value = aws_cloudwatch_log_group.lambda_log_group.arn
}

output "sns_topic_arn" {
  description = "ARN of the created SNS topic"
  value       = aws_sns_topic.topic.arn
}

output "endpoint_sftp" {
  description = "sftp endpoint to connect"
  value       = aws_transfer_server.transfer_server.endpoint
}

