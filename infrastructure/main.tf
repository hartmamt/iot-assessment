terraform {
  required_version = ">= 0.12.24"
}

provider aws {
  version = ">= 2.57.0"
  region = "us-east-2"
}

# Your HCL goes below! You got this!

# This is required to get the AWS region via ${data.aws_region.current}.
data "aws_region" "current" {
}

module "s3module" {
  source = "./s3"
  iot_prefix=var.iot_prefix
}

module "cloudfront" {
  source = "./cloudfront"
  iot_prefix = var.iot_prefix
  bucket_regional_domain_name = module.s3module.bucket_regional_domain_name
}

module "cognito" {
  source = "./cognito"
  domain_name = module.cloudfront.domain_name
  iot_prefix=var.iot_prefix
  post_confirmation_lambda_name = module.lambda.post_confirmation_lamda_name
  post_confirmation_lambda_arn = module.lambda.post_confirmation_lambda_arn
}

module "dynamodb" {
  source = "./dynamodb"
  iam_role_userAPI_id = module.lambda.iam_role_userAPI_id
}

module "lambda" {
  source = "./lambda"
}

module "api_gateway" {
  source = "./api_gateway"
  provider_arns = [module.cognito.pool_arn]
  region = data.aws_region.current.name
  user_api_lambda_arn = module.lambda.user_api_arn
}