data "aws_route53_zone" "main" {
  name = var.domain_name
}

module "acm" {
  source = "../modules/acm"
  
  domain_name = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
  zone_id     = data.aws_route53_zone.main.zone_id
  
  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

module "s3" {
  source = "../modules/s3"
  
  cloudfront_arn = module.cloudfront.distribution_arn
}

module "cloudfront" {
  source = "../modules/cloudfront"
  
  s3_domain_name  = module.s3.bucket_regional_domain_name
  s3_bucket_name  = module.s3.bucket_name
  certificate_arn = module.acm.certificate_arn
}

module "route53" {
  source = "../modules/route53"
  
  domain_name             = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
  cloudfront_domain_name  = module.cloudfront.domain_name
  cloudfront_zone_id      = module.cloudfront.hosted_zone_id
}

output "cloudfront_url" {
  value = module.cloudfront.domain_name
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "website_url" {
  value = module.route53.fqdn
}