resource "aws_s3_bucket_lifecycle_configuration" "state" {
  depends_on = [aws_s3_bucket_versioning.state]

  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.backend.noncurrent_version_expiration_days
    }
  }
}
