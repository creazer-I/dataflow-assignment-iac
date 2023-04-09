data "aws_caller_identity" "current" {}

resource "aws_transfer_server" "transfer_server" {
  endpoint_type          = "PUBLIC"
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.transfer_cloudwatch_role.arn
  tags = {
    Name = "transfer-server-dump-s3"
  }
}

resource "aws_transfer_user" "agents" {
  for_each = var.transfer_agents

  server_id      = aws_transfer_server.transfer_server.id
  user_name      = each.key
  home_directory = "/${module.transfer_bucket.s3_bucket_id}/${each.value}"
  role           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${each.key}-transfer-sftp-user-role"
}



