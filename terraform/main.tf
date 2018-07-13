# this certificate is in us-east-1 because cloudfront needs it to be.
resource "aws_acm_certificate" "cloudfront_certificate" {
  // We want a wildcard cert so we can host subdomains later.
  domain_name = "*.${var.root_domain}"

  // set validation method to dns
  // we'll show the dns settings at the end
  validation_method = "DNS"

  // make the certificate valid for the root domain too. 
  // This is optional, so remove it if you don't want to redirect to a specific subdomain.
  subject_alternative_names = ["${var.root_domain}"]

  provider = "aws.us_east_provider"
}

module "api" {
  source = "./api"

  aws_secret_key_id = "${var.aws_secret_key_id}"

  aws_secret_key = "${var.aws_secret_key}"

  aws_region = "${var.aws_region}"

  stage = "${var.stage}"

  subdomain = "${var.api_subdomain}"

  root_domain = "${var.root_domain}"

  certificate_arn = "${aws_acm_certificate.cloudfront_certificate.arn}"
}

# module "ui" {
#   source = "./ui"
#   aws_secret_key_id = "${var.aws_secret_key_id}"
#   aws_secret_key = "${var.aws_secret_key}"
#   aws_region = "${var.aws_region}"
#   stage = "${var.stage}"
#   subdomain = "${var.subdomain}"
#   root_domain = "${var.root_domain}"
# }

