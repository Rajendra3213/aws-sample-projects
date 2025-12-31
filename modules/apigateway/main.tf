resource "aws_iam_role" "api_role" {
  name = "${replace(var.api_name, " ", "-")}-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_policy" {
  name = "${replace(var.api_name, " ", "-")}-dynamodb-policy"
  role = aws_iam_role.api_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DescribeTable"
        ]
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = "API Gateway for DynamoDB operations"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [var.cognito_user_pool_arn]
}

resource "aws_api_gateway_authorizer" "lambda" {
  name                   = "lambda-authorizer"
  rest_api_id           = aws_api_gateway_rest_api.api.id
  authorizer_uri        = var.lambda_invoke_arn
  authorizer_credentials = aws_iam_role.api_role.arn
  type                  = "REQUEST"
  identity_source       = "method.request.header.Authorization"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# PUT resource
resource "aws_api_gateway_resource" "put" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "put"
}

resource "aws_api_gateway_method" "put" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.put.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda.id
}

resource "aws_api_gateway_integration" "put" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.put.id
  http_method             = aws_api_gateway_method.put.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/PutItem"
  credentials             = aws_iam_role.api_role.arn

  request_templates = {
    "application/json" = file("${var.vtl_dir}/putItem.vtl")
  }
}

resource "aws_api_gateway_method_response" "put" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.put.id
  http_method = aws_api_gateway_method.put.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "put" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.put.id
  http_method = aws_api_gateway_method.put.http_method
  status_code = aws_api_gateway_method_response.put.status_code

  response_templates = {
    "application/json" = file("${var.vtl_dir}/response.vtl")
  }
}

# GET resource
resource "aws_api_gateway_resource" "get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "get"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.get.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.get.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/Scan"
  credentials             = aws_iam_role.api_role.arn

  request_templates = {
    "application/json" = file("${var.vtl_dir}/scan_request.vtl")
  }
}

resource "aws_api_gateway_method_response" "get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.get.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.get.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.get.status_code

  response_templates = {
    "application/json" = file("${var.vtl_dir}/scan.vtl")
  }
}

# DELETE resource
resource "aws_api_gateway_resource" "delete" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "delete"
}

resource "aws_api_gateway_resource" "delete_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.delete.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "delete" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.delete_id.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "delete" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.delete_id.id
  http_method             = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/DeleteItem"
  credentials             = aws_iam_role.api_role.arn

  request_templates = {
    "application/json" = file("${var.vtl_dir}/deleteItem.vtl")
  }
}

resource "aws_api_gateway_method_response" "delete" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.delete_id.id
  http_method = aws_api_gateway_method.delete.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "delete" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.delete_id.id
  http_method = aws_api_gateway_method.delete.http_method
  status_code = aws_api_gateway_method_response.delete.status_code

  response_templates = {
    "application/json" = "{\"message\": \"Item deleted\"}"
  }
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.put,
    aws_api_gateway_method.get,
    aws_api_gateway_method.delete,
    aws_api_gateway_method.docs,
    aws_api_gateway_integration.put,
    aws_api_gateway_integration.get,
    aws_api_gateway_integration.delete,
    aws_api_gateway_integration.docs
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.docs.id,
      aws_api_gateway_method.docs.id,
      aws_api_gateway_integration.docs.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  variables = {
    TableName = var.dynamodb_table_name
  }
}

# API Key and Usage Plan
resource "aws_api_gateway_api_key" "key" {
  name = "${replace(var.api_name, " ", "-")}-key"
}

resource "aws_api_gateway_usage_plan" "plan" {
  name = "${replace(var.api_name, " ", "-")}-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_deployment.deployment.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "plan_key" {
  key_id        = aws_api_gateway_api_key.key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.plan.id
}

# API Documentation
resource "aws_api_gateway_documentation_version" "docs" {
  version     = "1.0"
  rest_api_id = aws_api_gateway_rest_api.api.id
  description = "API Documentation v1.0"

  depends_on = [
    aws_api_gateway_documentation_part.api,
    aws_api_gateway_documentation_part.put_method,
    aws_api_gateway_documentation_part.get_method,
    aws_api_gateway_documentation_part.delete_method
  ]
}

# Export documentation as OpenAPI/Swagger
resource "aws_api_gateway_model" "swagger" {
  rest_api_id  = aws_api_gateway_rest_api.api.id
  name         = "swagger"
  content_type = "application/json"
  schema = jsonencode({
    type = "object"
  })
}

# Create a resource to serve documentation
resource "aws_api_gateway_resource" "docs" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "docs"
}

resource "aws_api_gateway_method" "docs" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.docs.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "docs" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.docs.id
  http_method = aws_api_gateway_method.docs.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "docs" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.docs.id
  http_method = aws_api_gateway_method.docs.http_method
  status_code = "200"

  response_models = {
    "text/html" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "docs" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.docs.id
  http_method = aws_api_gateway_method.docs.http_method
  status_code = "200"

  depends_on = [aws_api_gateway_integration.docs]

  response_templates = {
    "text/html" = <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>API Documentation</title>
    <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@3.25.0/swagger-ui.css" />
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@3.25.0/swagger-ui-bundle.js"></script>
    <script>
        SwaggerUIBundle({
            url: 'https://67egqfhr64.execute-api.us-east-1.amazonaws.com/prod/swagger.json',
            dom_id: '#swagger-ui',
            presets: [
                SwaggerUIBundle.presets.apis,
                SwaggerUIBundle.presets.standalone
            ]
        });
    </script>
</body>
</html>
EOF
  }
}

resource "aws_api_gateway_documentation_part" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  location {
    type = "API"
  }
  properties = jsonencode({
    description = "DynamoDB CRUD API"
    info = {
      title   = "DynamoDB API"
      version = "1.0"
    }
  })
}

resource "aws_api_gateway_documentation_part" "put_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  location {
    type   = "METHOD"
    method = "POST"
    path   = "/put"
  }
  properties = jsonencode({
    summary     = "Create item in DynamoDB"
    description = "Creates a new item with ID, FirstName, and Age"
    parameters = {
      "Authorization" = {
        description = "Lambda authorizer token"
        required    = true
        type        = "string"
      }
    }
  })
}

resource "aws_api_gateway_documentation_part" "get_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  location {
    type   = "METHOD"
    method = "GET"
    path   = "/get"
  }
  properties = jsonencode({
    summary     = "Scan DynamoDB table"
    description = "Returns all items from the table"
    parameters = {
      "x-api-key" = {
        description = "API key for authentication"
        required    = true
        type        = "string"
      }
    }
  })
}

resource "aws_api_gateway_documentation_part" "delete_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  location {
    type   = "METHOD"
    method = "POST"
    path   = "/delete/{id}"
  }
  properties = jsonencode({
    summary     = "Delete item from DynamoDB"
    description = "Deletes an item by ID"
    parameters = {
      "Authorization" = {
        description = "Cognito JWT token"
        required    = true
        type        = "string"
      }
      "id" = {
        description = "Item ID to delete"
        required    = true
        type        = "string"
      }
    }
  })
}

data "aws_region" "current" {}