output "domain_name" {
  value = element(aws_cloudfront_distribution.demosstaticweb_distribution.origin[*].domain_name,0)
}