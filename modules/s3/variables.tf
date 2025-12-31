variable "cloudfront_arn" {
  type = string
}

output "bucket_name" {
  value = aws_s3_bucket.website.bucket
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.website.bucket_regional_domain_name
}

output "bucket_arn" {
  value = aws_s3_bucket.website.arn
}