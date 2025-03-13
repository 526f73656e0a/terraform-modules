# Terraform S3 Module Example

This folder contains two examples of S3 configurations using the [s3](../../s3) Terraform Module.

## Table of Contents

* [Minimal Example](#minimal-example)
	+ [Module Source and Name](#module-source-and-name)
	+ [Logging Bucket and KMS Key](#logging-bucket-and-kms-key)
	+ [Object Ownership and ACL](#object-ownership-and-acl)
	+ [Versioning and Public Access](#versioning-and-public-access)
	+ [Bucket Notification Events](#bucket-notification-events)
	+ [Lifecycle Rules](#lifecycle-rules)
	+ [Abort Incomplete Multipart Upload](#abort-incomplete-multipart-upload)
	+ [CloudFront and CORS](#cloudfront-and-cors)
	+ [Tags](#tags)
* [Full Example Bucket Configuration](#full-example-bucket-configuration)
	+ [Module Source and Name](#module-source-and-name-1)
	+ [Logging Bucket and KMS Key](#logging-bucket-and-kms-key-1)
	+ [Object Ownership and ACL](#object-ownership-and-acl-1)
	+ [Versioning and Public Access](#versioning-and-public-access-1)
	+ [Bucket Notification Events](#bucket-notification-events-1)
	+ [Lifecycle Rules](#lifecycle-rules-1)
	+ [Abort Incomplete Multipart Upload](#abort-incomplete-multipart-upload-1)
	+ [CloudFront and CORS](#cloudfront-and-cors-1)
	+ [Tags](#tags-1)


## Minimal Example

The minimal example can be found in the [s3_minimal](./s3_minimal.tf) file.
Here's a breakdown of the configuration:

### Module Source and Name

The `s3_minimal` module is sourced from `../../s3` and has a name that includes a random prefix and suffix.

```terraform
module "s3_minimal_example" {
  source = "../../s3"

  name = "${random_string.prefix.id}-minimal-example-bucket-${random_string.suffix.id}"
```

### Logging Bucket and KMS Key

No access logs are enabled

### Object Ownership and ACL

The object ownership is set to `ObjectWriter` and the ACLs are set to `Private` by default

### Versioning and Public Access

Versioning is enabled, and public access is not allowed by default

### Bucket Notification Events

No notifications on bucket events are configured

### Lifecycle Rules

The only Lifecycle Rule that is configured is a lifecycle rule that aborts multipart uploads after 7 days

### Abort Incomplete Multipart Upload

The `abort_incomplete_multipart_upload_days` attribute is not set and the default value  of 7 is taken

### CloudFront and CORS

CloudFront is not enabled, and no CORS rules are present by default

### Tags

The bucket has no tags

## Full Example Bucket Configuration

The full example bucket configuration is defined in the `s3_full.tf` file and utilizes the `s3` module. Here's a breakdown of the configuration:

### Module Source and Name

The `s3_full_example` module is sourced from `../../s3` and has a name that includes a random prefix and suffix.

```terraform
module "s3_full_example" {
  source = "../../s3"

  name = "${random_string.prefix.id}-full-example-bucket-${random_string.suffix.id}"
```

### Logging Bucket and KMS Key

The logging bucket is set to the ID of the `logging` module, and the KMS key is set to a specific ARN.

```terraform
logging_bucket_name = module.logging.id

```

### Object Ownership and ACL

The object ownership is set to `BucketOwnerPreferred`, and the ACL is set to `private`.

```terraform
object_ownership = "BucketOwnerPreferred"
acl              = "private"
```

### Versioning and Public Access

Versioning is enabled, and public access is not allowed.

```terraform
versioning = true
allow_public_access = false
```

### Bucket Notification Events

The bucket is configured to send a message to SNS on the `s3:ObjectCreated` event.

```terraform
bucket_notification_events = [
  {
    events    = ["s3:ObjectCreated:*"]
    topic_arn = aws_sns_topic.example.arn
  }
]
```

### Lifecycle Rules

The bucket has lifecycle rules configured for objects with a prefix of `incoming/`. The rules include:

* Transitioning to `GLACIER` storage class after 2 days
* Expiring non-current versions after 14 days
* Transitioning to `ONEZONE_IA` storage class after 30 days
* Transitioning to `GLACIER` storage class after 60 days
* Expiring objects after 120 days

```terraform
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
```

### Abort Incomplete Multipart Upload

The `abort_incomplete_multipart_upload_days` attribute is set to `-1`, which means that incomplete multipart uploads will not be aborted.

```terraform
abort_incomplete_multipart_upload_days = -1
```

### CloudFront and CORS

CloudFront is not enabled, and CORS rules are defined for GET and PUT requests.

```terraform
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
```

### Tags

The bucket is tagged with `Environment = "test"` and `Terraform = "true"`.

```terraform
tags = {
  Environment = "test"
  Terraform   = "true"
}
```