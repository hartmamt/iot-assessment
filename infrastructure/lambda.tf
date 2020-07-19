
# Define a Lambda function.
#
# The handler is the name of the executable for go1.x runtime.
resource "aws_lambda_function" "userAPI" {
  function_name = "userAPI"
  filename      = "../src/lambdas/userAPI/userAPI.zip"
  handler       = "userAPI"
  source_code_hash = filebase64sha256("../src/lambdas/userAPI/userAPI.zip")
  role             = aws_iam_role.userAPI.arn
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 1
}

resource "aws_lambda_function" "postConfirmation" {
  function_name = "postConfirmation"
  filename      = "../src/lambdas/postConfirmation/postConfirmation.zip"
  handler       = "postConfirmation"
  source_code_hash = filebase64sha256("../src/lambdas/postConfirmation/postConfirmation.zip")
  role             = aws_iam_role.userAPI.arn
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

resource "aws_iam_role" "userAPI" {
  name               = "userAPI"
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

# Allow API gateway to invoke the userAPI Lambda function.
resource "aws_lambda_permission" "userAPI" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.userAPI.arn
  principal     = "apigateway.amazonaws.com"
}