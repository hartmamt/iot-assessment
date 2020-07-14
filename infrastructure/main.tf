terraform {
  required_version = ">= 0.12.24"
}

provider aws {
  version = ">= 2.57.0"
  region = "us-east-2"
}

# Your HCL goes below! You got this!

# This holds the prefix to avoid naming collisions
variable "iot_prefix" {
  type = string
  default = "hogwarts"
}

# This is required to get the AWS region via ${data.aws_region.current}.
data "aws_region" "current" {
}

# Define a Lambda function.
#
# The handler is the name of the executable for go1.x runtime.
resource "aws_lambda_function" "getUser" {
  function_name = "getUser"
  filename      = "../api/getUser.zip"
  handler       = "getUser"
  source_code_hash = filebase64sha256("../api/getUser.zip")
  role             = aws_iam_role.getUser.arn
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 1
}

resource "aws_lambda_function" "postConfirmation" {
  function_name = "postConfirmation"
  filename      = "../postconfirmation/postConfirmation.zip"
  handler       = "postConfirmation"
  source_code_hash = filebase64sha256("../postconfirmation/postConfirmation.zip")
  role             = aws_iam_role.getUser.arn
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 1
}

# A Lambda function may access to other AWS resources such as S3 bucket. So an
# IAM role needs to be defined. This hello world example does not access to
# any resource, so the role is empty.
#
# The date 2012-10-17 is just the version of the policy language used here [1].
#
# [1]: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_version.html

resource "aws_iam_role" "getUser" {
  name               = "getUser"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    },
    "Effect": "Allow"
  }
}
POLICY
}

# Allow API gateway to invoke the getUser Lambda function.
resource "aws_lambda_permission" "getUser" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getUser.arn
  principal     = "apigateway.amazonaws.com"
}

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
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.getUser.arn}/invocations"
}

resource "aws_api_gateway_integration" "putUser" {
  rest_api_id             = aws_api_gateway_rest_api.users.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.putUser.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.getUser.arn}/invocations"
}

# This resource defines the URL of the API Gateway.
resource "aws_api_gateway_deployment" "users_v1" {
  depends_on = [
    aws_api_gateway_integration.users
  ]
  rest_api_id = aws_api_gateway_rest_api.users.id
  stage_name  = "v1"
}

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

resource "template_file" "s3policy" {
  template = <<-EOT
{
  "Version":"2012-10-17",
  "Statement":[{
	"Sid":"PublicReadGetObject",
        "Effect":"Allow",
	  "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.iot_prefix}-demos3staticweb/*"
      ]
    }
  ]
}
EOT
}

resource "aws_s3_bucket" "static_website_bucket" {
  bucket = "${var.iot_prefix}-demos3staticweb"
  acl    = "public-read"

  tags = {
    Name        = "DemoAWSS3StaticWeb"
    Environment = "production"
  }

  policy = template_file.s3policy.rendered

  website {
    index_document = "index.html"
  }
}

resource "null_resource" "upload_html_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ../static/html s3://${aws_s3_bucket.static_website_bucket.id}"
  }
}

resource "null_resource" "upload_css_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ../static/css s3://${aws_s3_bucket.static_website_bucket.id}"
  }
}


resource "aws_cloudfront_distribution" "demos3staticweb_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_website_bucket.bucket_regional_domain_name
    origin_id   = "S3-${var.iot_prefix}-demos3staticweb"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.iot_prefix}-demos3staticweb"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  tags = {
    Environment = "production"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_api_gateway_authorizer" "this" {
  name          = "CognitoUserPoolAuthorizer"
  identity_source = "method.request.header.Authorization"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.users.id
  provider_arns = [aws_cognito_user_pool.pool.arn]
}

resource "aws_dynamodb_table" "someTable" {
  name              = "someTable"
  read_capacity     = 5
  write_capacity    = 5
  hash_key          = "username"

  attribute {
    name = "username"
    type = "S"
  }
}

# POLICIES
resource "aws_iam_role_policy" "db_policy" {
  name = "db_policy"
  role = aws_iam_role.getUser.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:*"
      ],
      "Resource": "${aws_dynamodb_table.someTable.arn}"
    }
  ]
}
EOF
}

output "loginurl" {
  value = "https://${aws_cognito_user_pool_domain.default.domain}.auth.${data.aws_region.current.name}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.client.id}&response_type=token&scope=email+openid&redirect_uri=https://${element(aws_cloudfront_distribution.demos3staticweb_distribution.origin[*].domain_name,0)}/index.html"
}

# Set the generated URL as an output. Run `terraform output url` to get this.
output "url" {
  value = "${aws_api_gateway_deployment.users_v1.invoke_url}${aws_api_gateway_resource.users.path}"
}
