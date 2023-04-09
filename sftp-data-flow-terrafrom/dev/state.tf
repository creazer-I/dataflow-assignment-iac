/* locals {
  bucket_name         = "transfer-data-transfer-tf"
  dynamodb_table_name = "terraform-state-lock"
}

module "backend_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name
  acl    = var.bucket["acl"]

  versioning = {
    enabled = var.bucket["versioning"]
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

}


resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = local.dynamodb_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
} */


# remote state config 

/* terraform {
  backend "s3" {
    bucket         = "transfer-data-transfer-tf"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
} */


terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}