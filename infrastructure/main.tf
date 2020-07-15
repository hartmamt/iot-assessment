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

output "loginurl" {
  value = "https://${aws_cognito_user_pool_domain.default.domain}.auth.${data.aws_region.current.name}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.client.id}&response_type=token&scope=email+openid&redirect_uri=https://${element(aws_cloudfront_distribution.demos3staticweb_distribution.origin[*].domain_name,0)}/index.html"
}

# Set the generated URL as an output. Run `terraform output url` to get this.
output "url" {
  value = "${aws_api_gateway_deployment.users_v1.invoke_url}${aws_api_gateway_resource.users.path}"
}
