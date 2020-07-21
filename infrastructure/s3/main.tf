resource "aws_s3_bucket" "static_website_bucket" {
  bucket = "${var.iot_prefix}-demosstaticweb"
  acl    = "public-read"

  tags = {
    Name        = "DemoAWSSStaticWeb"
    Environment = "production"
  }

  policy = data.aws_iam_policy_document.s3_bucket_policy_document.json

  website {
    index_document = "index.html"
  }
}

data "aws_iam_policy_document" "s3_bucket_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.iot_prefix}-demosstaticweb/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
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
//
//resource "template_file" "s3policy" {
//  template = <<-EOT
//{
//  "Version":"2012-10-17",
//  "Statement":[{
//	"Sid":"PublicReadGetObject",
//        "Effect":"Allow",
//	  "Principal": "*",
//      "Action":["s3:GetObject"],
//      "Resource":["arn:aws:s3:::${var.iot_prefix}-demosstaticweb/*"
//      ]
//    }
//  ]
//}
//EOT
//}

