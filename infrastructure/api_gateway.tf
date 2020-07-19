
# A Lambda function is not a usual public REST API. We need to use AWS API
# Gateway to map a Lambda function to an HTTP endpoint.
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.users.id
  parent_id   = aws_api_gateway_rest_api.users.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_rest_api" "users" {
  name = "users"
}

#           GET
# Internet -----> API Gateway
resource "aws_api_gateway_method" "users" {
  rest_api_id   = aws_api_gateway_rest_api.users.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

#           PUT
# Internet -----> API Gateway
resource "aws_api_gateway_method" "putUser" {
  rest_api_id   = aws_api_gateway_rest_api.users.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

#              POST
# API Gateway ------> Lambda
# For Lambda the method is always POST and the type is always AWS_PROXY.
#
# The date 2015-03-31 in the URI is just the version of AWS Lambda.
resource "aws_api_gateway_integration" "users" {
  rest_api_id             = aws_api_gateway_rest_api.users.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.users.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.userAPI.arn}/invocations"
}

resource "aws_api_gateway_integration" "putUser" {
  rest_api_id             = aws_api_gateway_rest_api.users.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.putUser.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.userAPI.arn}/invocations"
}

# This resource defines the URL of the API Gateway.
resource "aws_api_gateway_deployment" "users_v1" {
  depends_on = [
    aws_api_gateway_integration.users
  ]
  rest_api_id = aws_api_gateway_rest_api.users.id
  stage_name  = "v1"
}

resource "aws_api_gateway_authorizer" "this" {
  name          = "CognitoUserPoolAuthorizer"
  identity_source = "method.request.header.Authorization"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.users.id
  provider_arns = [aws_cognito_user_pool.pool.arn]
}