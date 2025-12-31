output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "root_resource_id" {
  description = "Root resource ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.root_resource_id
}

output "api_url" {
  description = "URL of the API Gateway"
  value       = aws_api_gateway_deployment.deployment.invoke_url
}

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "documentation_url" {
  description = "API documentation URL"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/prod/docs"
}

output "api_key" {
  description = "API key for accessing the API"
  value       = aws_api_gateway_api_key.key.value
  sensitive   = true
}