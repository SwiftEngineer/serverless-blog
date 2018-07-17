// We want AWS to host our zone so its nameservers can point to our CloudFront
// distribution.

data "aws_route53_zone" "zone" {
  name = "${var.root_domain}"
}

// This Route53 record will point at our CloudFront distribution.
resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "${var.subdomain}.${var.root_domain}"
  type    = "A"

  alias = {
    name                   = "${aws_cloudfront_distribution.client_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.client_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
