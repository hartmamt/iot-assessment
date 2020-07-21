output "user_api_arn" {
  value = aws_lambda_function.userAPI.arn
}

output "post_confirmation_lamda_name" {
  value = aws_lambda_function.postConfirmation.function_name
}

output "post_confirmation_lambda_arn" {
  value = aws_lambda_function.postConfirmation.arn
}

output "iam_role_userAPI_id" {
  value=aws_iam_role.userAPI.id
}