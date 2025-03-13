module "s3_full_example" {
  source = "../../s3"

  name                = "${random_string.prefix.id}-full-example-bucket-${random_string.suffix.id}"
  logging_bucket_name = module.logging.id

  kms_key = aws_kms_key.example.arn

  object_ownership    = "BucketOwnerPreferred"
  acl                 = "private"
  allow_public_access = false

  versioning = true

  bucket_notification_events = [
    {
      events    = ["s3:ObjectCreated:*"]
      topic_arn = aws_sns_topic.example.arn
    }
  ]

  lifecycle_rules = [
    {
      id     = "incoming"
      status = "Enabled"
      prefix = "incoming/"
      tags   = null
      noncurrent_version_transition = [
        {
          days          = 2
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration = {
        days = 14
      }
      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 120
      }
    }
  ]
  abort_incomplete_multipart_upload_days = -1


  cloudfront = false
  cors_rule = [
    {
      allowed_methods = ["GET"]
      allowed_origins = ["https://example.html"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_methods = ["PUT"]
      allowed_origins = ["https://import"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  tags = {
    Environment = "test"
    Terraform   = "true"
  }
}