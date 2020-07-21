output "invoke_url" {
  value = aws_api_gateway_deployment.users_v1.invoke_url
}

output "users_path" {
  value = aws_api_gateway_resource.users.path
}
