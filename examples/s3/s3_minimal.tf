module "s3_minimal_example" {
  source = "../../s3"
  name   = "${random_string.prefix.id}-minimal-example-bucket-${random_string.suffix.id}"
}