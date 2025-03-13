locals {
  all_lifecycle_rules = concat(var.lifecycle_rules, local.default_multipart_rule)
  default_multipart_rule = (!local.has_multipart_rule && var.abort_incomplete_multipart_upload_days > 0) ? [{
    id                                     = "abort-incomplete-multipart-uploads"
    status                                 = "Enabled"
    abort_incomplete_multipart_upload_days = var.abort_incomplete_multipart_upload_days
    prefix                                 = null
    tags                                   = null
    expiration                             = null
    transition                             = []
    noncurrent_version_transition          = []
    noncurrent_version_expiration          = null
  }] : []
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_configuration" {
  count  = length(local.all_lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = local.all_lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      # Only include filter if prefix or tags are specified
      dynamic "filter" {
        for_each = rule.value.prefix != null || rule.value.tags != null ? [1] : []
        content {
          dynamic "and" {
            for_each = rule.value.prefix != null && rule.value.tags != null ? [1] : []
            content {
              prefix = rule.value.prefix
              tags   = rule.value.tags
            }
          }

          # If only prefix is provided without tags
          prefix = rule.value.prefix != null && rule.value.tags == null ? rule.value.prefix : null

          # If only tags are provided without prefix
          dynamic "tag" {
            for_each = rule.value.prefix == null && rule.value.tags != null ? rule.value.tags : {}
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # Handle abort_incomplete_multipart_upload if specified
      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload_days != null ? [rule.value.abort_incomplete_multipart_upload_days] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }

      # Handle expiration if specified
      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          date                         = expiration.value.date
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      # Handle transitions if specified
      dynamic "transition" {
        for_each = rule.value.transition
        content {
          date          = transition.value.date
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      # Handle noncurrent_version_transitions if specified
      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      # Handle noncurrent_version_expiration if specified
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.days
        }
      }
    }
  }
}