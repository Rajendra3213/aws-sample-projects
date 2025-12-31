variable "domain_name" {
  type = string
}

variable "zone_id" {
  type = string
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.website.certificate_arn
}