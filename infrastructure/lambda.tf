
# Define a Lambda function.
#
# The handler is the name of the executable for go1.x runtime.
resource "aws_lambda_function" "getUser" {
  function_name = "getUser"
  filename      = "../api/bin/getUser.zip"
  handler       = "getUser"
  source_code_hash = filebase64sha256("../api/bin/getUser.zip")
  role             = aws_iam_role.getUser.arn
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 1
}

resource "aws_lambda_function" "postConfirmation" {
  function_name = "postConfirmation"
  filename      = "../postconfirmation/bin/postConfirmation.zip"
  handler       = "postConfirmation"
  source_code_hash = filebase64sha256("../postconfirmation/bin/postConfirmation.zip")
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