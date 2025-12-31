variable "domain_name" {
  type = string
}

variable "subdomain" {
  type    = string
  default = ""
}

variable "cloudfront_domain_name" {
  type = string
}

variable "cloudfront_zone_id" {
  type = string
}

output "zone_id" {
  value = data.aws_route53_zone.main.zone_id
}

output "fqdn" {
  value = aws_route53_record.website.fqdn
}