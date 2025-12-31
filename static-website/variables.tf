variable "domain_name" {
  type = string
}

variable "subdomain" {
  type    = string
  default = ""
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}