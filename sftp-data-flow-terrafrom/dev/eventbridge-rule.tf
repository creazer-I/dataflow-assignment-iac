locals {
  schedule_expression = "cron(0 17 * * ? *)" # 5 PM Ireland(eu-west-1)
}

# eventbridge rule 

resource "aws_cloudwatch_event_rule" "eventbridge_rule" {
  name        = var.eventbridge_rule_name
  description = "EventBridge rule to trigger Lambda function at 5 PM Irish time"

  schedule_expression = local.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.eventbridge_rule.name
  arn       = aws_lambda_function.alert_lambda_function.arn
  target_id = "lambda-target"
}