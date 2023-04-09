# aws transfer family - cloudwatch logs
resource "aws_cloudwatch_log_group" "transfer_logs" {
  name              = "/aws/transfer/${aws_transfer_server.transfer_server.id}"
  retention_in_days = 7
}

# lambda function - cloudwatch logs
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.alert_lambda_function.id}"
  retention_in_days = 7
}



