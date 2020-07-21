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
  role = var.iam_role_userAPI_id
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