resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name

  auto_verified_attributes = ["email"]

  username_attributes = ["email"]

  schema {
    attribute_data_type = "String"
    name               = "email"
    required           = true
    mutable           = false
  }

  tags = var.tags
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "${var.user_pool_name}-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  callback_urls = ["http://localhost"]

  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows_user_pool_client = true

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.pool.id
}