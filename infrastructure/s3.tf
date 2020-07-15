resource "aws_s3_bucket" "static_website_bucket" {
  bucket = "${var.iot_prefix}-demos3staticweb"
  acl    = "public-read"

  tags = {
    Name        = "DemoAWSS3StaticWeb"
    Environment = "production"
  }

  policy = template_file.s3policy.rendered

  website {
    index_document = "index.html"
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

resource "template_file" "s3policy" {
  template = <<-EOT
{
  "Version":"2012-10-17",
  "Statement":[{
	"Sid":"PublicReadGetObject",
        "Effect":"Allow",
	  "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.iot_prefix}-demos3staticweb/*"
      ]
    }
  ]
}
EOT
}