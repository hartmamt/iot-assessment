#Output the URL used to sign up / sign in
output "loginurl" {
  value = "https://${module.cognito.default_domain}.auth.${data.aws_region.current.name}.amazoncognito.com/login?client_id=${module.cognito.client_id}&response_type=token&scope=email+openid&redirect_uri=https://${module.cloudfront.domain_name}/index.html"
}

# Set the generated URL as an output. Run `terraform output url` to get this.
output "CHALLENGE_URL" {
  value = "${module.api_gateway.invoke_url}${module.api_gateway.users_path}"
}