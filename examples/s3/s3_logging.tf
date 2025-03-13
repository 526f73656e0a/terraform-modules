provider "random" {
}

resource "random_string" "prefix" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}

module "logging" {
  source = "../../s3"

  name                   = "${random_string.prefix.id}-access-logs-${random_string.suffix.id}"
  enable_logging_service = true
  # logging_bucket_name = module.logging.id # This will be the access logging bucket for the account


  object_ownership    = "BucketOwnerPreferred"
  acl                 = "private"
  allow_public_access = false

  versioning = false

  tags = {
    Environment = "test"
    Terraform   = "true"
  }
}