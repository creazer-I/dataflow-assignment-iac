resource "aws_sns_topic" "topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "topic_subscription" {
  for_each  = { for email in var.email_addresses : email => email }
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = each.value
}
