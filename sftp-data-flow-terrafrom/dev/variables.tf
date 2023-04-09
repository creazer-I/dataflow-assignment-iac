variable "env" {
  type = string
  description = "Environment"
}

variable "region" {
  type        = string
  description = "The AWS region where the resources will be created"
}

variable "bucket" {
  type = any
  default = {
    acl        = "private"
    versioning = true
  }
}

variable "transfer_agents" {
  type = map(string)
  default = {
  # "Username" = "directory name for s3"
    "transfer-agent1" = "transfer-agent1"
    "transfer-agent2" = "transfer-agent2"
  }
  description = "Username and directory path name for aws transfer family sftp"
}

variable "email_addresses" {
  type        = list(string)
  description = "Enter the list of emails of sre team for SNS"
}

variable "eventbridge_rule_name" {
  description = "The name of the EventBridge rule to be created"
  default     = "lambda-scheduled-trigger"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function to be created"
  default     = "my_lambda_function"
}

variable "iam_role_name" {
  description = "The name of the IAM role for Lambda execution"
  default     = "lambda_execution_role"
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "sre-team"
}