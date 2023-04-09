module "transfer_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "dev-transfer-file-bucket"
  acl    = var.bucket["acl"]

  versioning = {
    enabled = var.bucket["versioning"]
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.s3_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

resource "aws_s3_bucket_policy" "dev-transfer-file-bucket-policy" {
  for_each = var.transfer_agents

  bucket = module.transfer_bucket.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowAccesstoS3",
        Action = [
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "${module.transfer_bucket.s3_bucket_arn}",
          "${module.transfer_bucket.s3_bucket_arn}/*"
        ],
        Principal = {
          AWS = [
            aws_iam_role.transfer_role[each.key].arn
          ]
        }
      }
    ]
  })
}


resource "aws_kms_key" "s3_key" {
  description = "kms key for the landing bucket"
}



