variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "zip_file" {
  description = "Path to the Lambda deployment package"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}