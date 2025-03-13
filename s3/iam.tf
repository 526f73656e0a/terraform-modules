resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = local.block_public_access
  block_public_policy     = local.block_public_access
  restrict_public_buckets = local.block_public_access
  ignore_public_acls      = local.block_public_access
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect  = "Allow"
    actions = local.versioning_action
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["arn:aws:s3:::${var.name}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = [
      "arn:aws:s3:::${var.name}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = [
      "arn:aws:s3:::${var.name}",
      "arn:aws:s3:::${var.name}/*"
    ]
  }

  dynamic "statement" {
    for_each = var.cloudfront ? [1] : []
    content {
      sid       = "AllowCloudFrontS3Access"
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::${var.name}/*"]
      condition {
        test     = "StringLike"
        variable = "AWS:SourceArn"
        values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"]
      }
      principals {
        type        = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.cloudfront ? [1] : []
    content {
      sid       = "AllowCloudFrontServicePrincipalReadOnlyRoot"
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::${var.name}/*"]
      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_logging_service ? [1] : []
    content {
      sid       = "AllowLoggingServiceAccess"
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["${aws_s3_bucket.bucket.arn}/*"]
      principals {
        type        = "Service"
        identifiers = ["logging.s3.amazonaws.com"]
      }
    }
  }
}