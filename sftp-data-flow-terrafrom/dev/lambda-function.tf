locals {
  fn_name = "alert-missing-sre"
}

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_dir  = "./python-function/"
  output_path = "./python-function/alert-missing-sre.zip"
}


resource "aws_lambda_function" "alert_lambda_function" {
  filename      = data.archive_file.python_lambda_package.output_path
  function_name = local.fn_name
  role          = aws_iam_role.alert_lambda_role.arn
  handler       = "${local.fn_name}.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      SNS_TOPIC_ARN       = aws_sns_topic.topic.arn
      Landing_Bucket_Name = module.transfer_bucket.s3_bucket_id
      Server_Id           = aws_transfer_server.transfer_server.id
    }
  }
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert_lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.eventbridge_rule.arn
}