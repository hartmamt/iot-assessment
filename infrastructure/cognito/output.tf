output "default_domain" {
  value = aws_cognito_user_pool_domain.default.domain
}

output "client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "pool_arn" {
  value = aws_cognito_user_pool.pool.arn
}