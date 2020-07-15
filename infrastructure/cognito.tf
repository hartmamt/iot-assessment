# Define Cognito User Pool
resource "aws_cognito_user_pool" "pool" {
  name = "${var.iot_prefix}Users"
  username_attributes = ["email"]
  auto_verified_attributes = ["email"]
  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = false
    required            = true

    string_attribute_constraints {
      min_length = 5
      max_length = 2048
    }
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${var.iot_prefix}-client"
  user_pool_id = aws_cognito_user_pool.pool.id
  supported_identity_providers = ["COGNITO"]
  logout_urls = ["https://${element(aws_cloudfront_distribution.demos3staticweb_distribution.origin[*].domain_name,0)}/index.html"]
  callback_urls = ["https://${element(aws_cloudfront_distribution.demos3staticweb_distribution.origin[*].domain_name,0)}/index.html"]
  allowed_oauth_flows = ["implicit"]
  allowed_oauth_scopes = ["email","openid"]
  allowed_oauth_flows_user_pool_client = true
}

resource "aws_cognito_user_pool_domain" "default" {
  domain       = "${var.iot_prefix}1"
  user_pool_id = aws_cognito_user_pool.pool.id
}