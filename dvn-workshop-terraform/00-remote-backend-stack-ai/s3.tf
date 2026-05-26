resource "aws_s3_bucket" "state" {
  bucket = var.backend.bucket_name
}
