# This is the ACM (Amazon Certificate Manager) certificate which proves
# to Amazon that we own the domain. This same cert will be used for
# all our TLS needs as well.
resource "aws_acm_certificate" "cloudfront_certificate" {
  # We want a wildcard cert so we can use this for all the different
  # subdomains across our app.
  domain_name = "*.${var.root_domain}"

  # set validation method to dns.
  # if you bought the cert from somwhere else you'll probably
  # have to change this to "EMAIL"
  validation_method = "DNS"

  # make the certificate valid for the root domain too. 
  # This is optional, so remove it if you want to make sure that
  # Route53 redirects from your root domain DON'T work.
  subject_alternative_names = ["${var.root_domain}"]

  provider = "aws.us_east_provider"

  # Tags to track costs.
  tags = {
    Project     = "${var.subdomain}.${var.root_domain}"
    ServiceType = "api"
  }
}

# route 53 zone for our domain.
# this is gonna be used by both the api and ui for DNS,
# so I'm gonna put it up here and pass it's zone_id down into
# each of the services that need it.
resource "aws_route53_zone" "zone" {
  name = "${var.root_domain}"

  # Tags to track costs.
  tags = {
    Project     = "${var.subdomain}.${var.root_domain}"
    ServiceType = "api"
  }
}

# This module describes the API infrastructure we want to provision.
# If you want to dig in, check out the code itself.
module "api" {
  # Path to the module's source. If you wanna learn more about the API,
  # check out the files in the `api/` folder.
  source = "./api"

  aws_secret_key_id = "${var.aws_secret_key_id}"

  aws_secret_key = "${var.aws_secret_key}"

  aws_region = "${var.aws_region}"

  stage = "${var.stage}"

  website_subdomain = "${var.subdomain}"

  subdomain = "${var.api_subdomain}"

  root_domain = "${var.root_domain}"

  certificate_arn = "${aws_acm_certificate.cloudfront_certificate.arn}"

  zone_id = "${aws_route53_zone.zone.zone_id}"

  api_version = "${var.api_version}"
}

# This module describes the UI infrastructure we want to provision.
# If you want to dig in, check out the code itself.
module "ui" {
  # Path to the module's source. If you wanna learn more about the UI,
  # check out the files in the `api/` folder.
  source = "./ui"

  aws_secret_key_id = "${var.aws_secret_key_id}"

  aws_secret_key = "${var.aws_secret_key}"

  aws_region = "${var.aws_region}"

  stage = "${var.stage}"

  subdomain = "${var.subdomain}"

  root_domain = "${var.root_domain}"

  certificate_arn = "${aws_acm_certificate.cloudfront_certificate.arn}"

  zone_id = "${aws_route53_zone.zone.zone_id}"

  ui_version = "${var.ui_version}"
}
