resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = length(var.bucket_notification_events) > 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "lambda_function" {
    for_each = [for notification in var.bucket_notification_events : notification if notification.lambda_function_arn != null]
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }

  dynamic "topic" {
    for_each = [for notification in var.bucket_notification_events : notification if notification.topic_arn != null]
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = [for notification in var.bucket_notification_events : notification if notification.queue_arn != null]
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }
}