terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "dynamodb" {
  source = "../modules/dynamodb"
  
  table_name = "MyTable"
  tags       = var.tags
}

module "lambda" {
  source = "../modules/lambda"
  
  function_name = "MyLambdaFunction"
  zip_file      = "src/lambda.zip"
  tags          = var.tags
}

module "cognito" {
  source = "../modules/cognito"
  
  user_pool_name = "my_user_pool"
  domain_prefix  = "a1faegn"
  tags           = var.tags
}

module "apigateway" {
  source = "../modules/apigateway"
  
  api_name               = "My Service"
  dynamodb_table_arn     = module.dynamodb.table_arn
  dynamodb_table_name    = module.dynamodb.table_name
  cognito_user_pool_arn  = module.cognito.user_pool_arn
  lambda_invoke_arn      = module.lambda.invoke_arn
  lambda_function_name   = module.lambda.function_name
  vtl_dir               = "vtl"
  tags                  = var.tags
}