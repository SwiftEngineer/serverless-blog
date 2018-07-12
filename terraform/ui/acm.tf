resource "aws_acm_certificate" "certificate" {
  // We want a wildcard cert so we can host subdomains later.
  domain = "*.${var.root_domain}"

  // set validation method to dns
  // we'll show the dns settings at the end
  validation_method = "DNS"

  // make the certificate valid for the root domain too. 
  // This is optional, so remove it if you don't want to redirect to a specific subdomain.
  subject_alternative_names = ["${var.root_domain}"]

  provider = "aws.us_east_provider"
}
