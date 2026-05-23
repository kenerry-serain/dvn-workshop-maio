output "s3_bucket_id" {
  description = "ID (name) do bucket S3 para terraform state."
  value       = aws_s3_bucket.state.id
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3 para terraform state."
  value       = aws_s3_bucket.state.arn
}

output "s3_bucket_region" {
  description = "Regiao AWS onde o bucket S3 esta provisionado."
  value       = aws_s3_bucket.state.bucket_region
}
