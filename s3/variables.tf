variable "name" {
  description = "The name of the bucket. (required)"
  type        = string
}

variable "tags" {
  description = "The tags to attach to the bucket."
  type        = map(string)
  default     = {}
}

variable "logging_bucket_name" {
  description = "The name of the logging bucket, must be created separately."
  type        = string
  default     = ""
}

variable "versioning" {
  description = "Whether to enable versioning for the bucket."
  type        = bool
  default     = true
}

variable "acl" {
  description = "The ACL to apply."
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public-read", "public-read-write", "authenticated-read", "aws-exec-read", "bucket-owner-read", "bucket-owner-full-control"], var.acl)
    error_message = "The ACL value must be one of: private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control."
  }
}

variable "kms_key" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption."
  type        = string
  default     = null
}

variable "object_ownership" {
  description = "The S3 object ownership setting (BucketOwnerPreferred, ObjectWriter, or BucketOwnerEnforced)."
  type        = string
  default     = "ObjectWriter"
  validation {
    condition     = contains(["BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"], var.object_ownership)
    error_message = "The object_ownership value must be one of: BucketOwnerPreferred, ObjectWriter, or BucketOwnerEnforced."
  }
}

variable "bucket_notification_events" {
  description = "Configuration for S3 bucket event notifications."
  type = list(object({
    events              = list(string)
    filter_prefix       = optional(string, "")
    filter_suffix       = optional(string, "")
    lambda_function_arn = optional(string, null)
    topic_arn           = optional(string, null)
    queue_arn           = optional(string, null)
  }))
  default = []
}

variable "allow_public_access" {
  description = "Whether to allow public access to the bucket. If ACL is set to 'private', public access is always blocked regardless of this setting."
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules to configure for the S3 bucket."
  type = list(object({
    id                                     = string
    status                                 = string
    prefix                                 = optional(string, null)
    tags                                   = optional(map(string), null)
    abort_incomplete_multipart_upload_days = optional(number, null)

    expiration = optional(object({
      date                         = optional(string, null)
      days                         = optional(number, null)
      expired_object_delete_marker = optional(bool, null)
    }), null)

    transition = optional(list(object({
      date          = optional(string, null)
      days          = optional(number, null)
      storage_class = string
    })), [])

    noncurrent_version_transition = optional(list(object({
      days          = number
      storage_class = string
    })), [])

    noncurrent_version_expiration = optional(object({
      days = number
    }), null)
  }))
  default = []
}

variable "abort_incomplete_multipart_upload_days" {
  description = "Number of days after which Amazon S3 aborts an incomplete multipart upload. Set to -1 to disable the automatic rule creation."
  type        = number
  default     = 7
  validation {
    condition     = var.abort_incomplete_multipart_upload_days == -1 || var.abort_incomplete_multipart_upload_days > 0
    error_message = "The abort_incomplete_multipart_upload_days must be a positive number or -1 to disable."
  }
}

variable "cloudfront" {
  description = "Whether to enable access from CloudFront distributions in the same account."
  type        = bool
  default     = false
}

variable "cors_rule" {
  description = "CORS configuration rules for the S3 bucket. Can be provided as JSON string or as a structured object."
  type        = any
  default     = []
}

variable "enable_logging_service" {
  description = "Whether to enable logging for the S3 bucket. Set this to enabled if you are creating a bucket for access logging."
  type        = bool
  default     = false
}