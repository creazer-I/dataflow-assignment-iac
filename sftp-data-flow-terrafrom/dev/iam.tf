# aws transfer user roles

resource "aws_iam_role" "transfer_role" {
  for_each    = var.transfer_agents
  name        = "${each.key}-transfer-sftp-user-role"
  description = "aws transfer family role for ${each.value}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
      }
    ]
  })

  lifecycle {
    ignore_changes = [
      description
    ]
  }
}

resource "aws_iam_policy" "transfer_policy" {
  for_each = var.transfer_agents
  name     = "${each.key}-transfer-server-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket"

        ]
        Effect = "Allow"
        Resource = [
          "${module.transfer_bucket.s3_bucket_arn}",
          "${module.transfer_bucket.s3_bucket_arn}/*"
        ]
      },
      {
        Action = [
          "s3:*"

        ]
        Effect = "Deny"
        Resource = [
          "${module.transfer_bucket.s3_bucket_arn}/*}"
        ]
      },
      {
        Action = [
          "s3:GetObject"
        ],
        Effect = "Allow",
        Resource = [
          "${module.transfer_bucket.s3_bucket_arn}/${each.value}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = "s3:PutObject",
        Resource = [
          "${module.transfer_bucket.s3_bucket_arn}/${each.value}/*.csv",
          "${module.transfer_bucket.s3_bucket_arn}/${each.value}/*.xls",
          "${module.transfer_bucket.s3_bucket_arn}/${each.value}/*.xlsx",
          "${module.transfer_bucket.s3_bucket_arn}/${each.value}/*.json"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "kms_policy" {
  name_prefix = "kms-policy-"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Stmt1544140969635",
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ],
        Resource = aws_kms_key.s3_key.arn
      }
    ]
  })
}

resource "aws_iam_role" "transfer_cloudwatch_role" {
  name = "transfer-server-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name_prefix = "cloudwatch-policy-transfer"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_cloudwatch_log_group.transfer_logs.arn}",
          "${aws_cloudwatch_log_group.transfer_logs.arn}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "transfer_attachment" {
  for_each   = var.transfer_agents
  role       = aws_iam_role.transfer_role[each.key].name
  policy_arn = aws_iam_policy.transfer_policy[each.key].arn
}

resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {
  for_each   = var.transfer_agents
  policy_arn = aws_iam_policy.kms_policy.arn
  role       = aws_iam_role.transfer_role[each.key].name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
  role       = aws_iam_role.transfer_cloudwatch_role.name
}

# lambda function role

resource "aws_iam_role" "alert_lambda_role" {
  name = "alert_lambda_function_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "alert_lambda_policy" {
  name = "alert_lambda_function_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = aws_cloudwatch_log_group.lambda_log_group.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_function" {
  policy_arn = aws_iam_policy.alert_lambda_policy.arn
  role       = aws_iam_role.alert_lambda_role.name
}

data "aws_iam_policy_document" "alert_lambda_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${module.transfer_bucket.s3_bucket_arn}",
      "${module.transfer_bucket.s3_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "transfer:ListServers",
      "transfer:ListUsers"
    ]
    resources = [
      "${aws_transfer_server.transfer_server.arn}",
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      "${aws_sns_topic.topic.arn}"
    ]
  }
}

resource "aws_iam_policy" "alert_lambda_s3_sftp_policy" {
  name   = "alert_lambda_policy"
  policy = data.aws_iam_policy_document.alert_lambda_policy_document.json
}

resource "aws_iam_role_policy_attachment" "alert_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.alert_lambda_s3_sftp_policy.arn
  role       = aws_iam_role.alert_lambda_role.name
}
