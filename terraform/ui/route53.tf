# This is where it all begins. The root of all evil.
# This is the DNS record that will forward requests for our website
# to the cloudfront distrubution that hosts it.
#
# Once the request goes to Cloudfront, it will be routed to the IP
# address of the most accessible source of the content based on
# where in the world the user is making the request from.
resource "aws_route53_record" "client_cloudfront_alias" {
  zone_id = "${var.zone_id}"
  name    = "${var.subdomain}.${var.root_domain}"
  type    = "A"

  alias = {
    name                   = "${aws_cloudfront_distribution.client_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.client_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# This alias does the same thing as the one above, but for the root domain.
# It wouldn't be necessary if we didn't want to redirect requests sent to our
# root domain to the cloudfront distro.
resource "aws_route53_record" "client_cloudfront_root_alias" {
  zone_id = "${var.zone_id}"
  name    = "${var.root_domain}"
  type    = "A"

  alias = {
    name                   = "${aws_cloudfront_distribution.client_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.client_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
