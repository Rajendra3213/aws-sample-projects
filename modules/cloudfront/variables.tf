variable "s3_domain_name" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "certificate_arn" {
  type    = string
  default = null
}