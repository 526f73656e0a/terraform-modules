locals {
  versioning_action = var.versioning ? ["s3:ListBucket", "s3:ListBucketVersions", "s3:GetBucketLocation"] : ["s3:ListBucket", "s3:GetBucketLocation"]

  block_public_access = var.acl == "private" ? true : !var.allow_public_access

  # Multipart upload rule handling
  has_multipart_rule = var.abort_incomplete_multipart_upload_days == -1 ? true : length([
    for rule in var.lifecycle_rules : rule
    if rule.abort_incomplete_multipart_upload_days != null
  ]) > 0

  cors_rules = try(jsondecode(var.cors_rule), var.cors_rule)

}

resource "aws_s3_bucket" "bucket" {
  bucket = var.name
  tags   = var.tags
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_logging" "logging" {
  count = var.logging_bucket_name != "" ? 1 : 0

  bucket        = aws_s3_bucket.bucket.id
  target_bucket = var.logging_bucket_name
  target_prefix = "unsorted/${var.name}/"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended" # Changed from "Disabled" to "Suspended" as per AWS API
  }
}

resource "aws_s3_bucket_acl" "acl" {
  bucket     = aws_s3_bucket.bucket.id
  acl        = var.acl
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  count  = var.kms_key != null ? 1 : 0 # Changed from boolean check to null check
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(local.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  dynamic "cors_rule" {
    for_each = local.cors_rules
    content {
      id              = try(cors_rule.value.id, null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = try(cors_rule.value.allowed_headers, null)
      expose_headers  = try(cors_rule.value.expose_headers, null)
      max_age_seconds = try(cors_rule.value.max_age_seconds, null)
    }
  }
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  count  = var.cloudfront ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

