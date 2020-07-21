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
  lambda_config {
    # exactly the same semantics as the lambda_config block on the aws_cognito_user_pool
    #post_confirmation = ""
    post_confirmation = var.post_confirmation_lambda_arn
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${var.iot_prefix}-client"
  user_pool_id = aws_cognito_user_pool.pool.id
  supported_identity_providers = ["COGNITO"]
  logout_urls = ["https://${var.domain_name}/index.html"]
  callback_urls = ["https://${var.domain_name}/index.html"]
  allowed_oauth_flows = ["implicit"]
  allowed_oauth_scopes = ["email","openid"]
  allowed_oauth_flows_user_pool_client = true
}

resource "aws_cognito_user_pool_domain" "default" {
  domain       = "${var.iot_prefix}1"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_lambda_permission" "allow_execution_from_user_pool" {
  statement_id = "AllowExecutionFromUserPool"
  action = "lambda:InvokeFunction"
  function_name = var.post_confirmation_lambda_name
  principal = "cognito-idp.amazonaws.com"
  source_arn = aws_cognito_user_pool.pool.arn
}


