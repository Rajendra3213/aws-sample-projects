output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = module.cognito.client_id
}

output "api_url" {
  description = "URL of the API Gateway"
  value       = module.apigateway.api_url
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.table_name
}

output "documentation_url" {
  description = "API documentation URL"
  value       = module.apigateway.documentation_url
}

output "api_key" {
  description = "API key for GET requests"
  value       = module.apigateway.api_key
  sensitive   = true
}