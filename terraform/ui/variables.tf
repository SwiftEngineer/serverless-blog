variable "aws_region" {
  description = "AWS region to launch service in."
  default     = "us-west-2"
}

variable "aws_secret_key_id" {
  description = "AWS secret key ID"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

variable "stage" {
  description = "Which environment we are deploying to. (examples: \"production\", \"prod\", \"staging\", \"stage\")"
  default     = "dev"
}

variable "subdomain" {
  description = "The subdomain used to access the website. (examples: \"www\", \"kanyewest\", \"iam\"...)"
}

variable "root_domain" {
  description = "You may know it as the zone apex or naked domain (examples: \"doyouknowtheway.com\", \"bestartist.net\", \"so.cool\"...)"
}

variable "certificate_arn" {
  description = "ARN of certificate to use for HTTPS and gateway domain."
}

variable "zone_id" {
  description = "Route53 Zone to place all our Route53 records in for DNS lookups."
}

variable "ui_version" {
  description = "Semantic version number for the website. (examples: \"1.0.0\", \"0.1.2\", \"1.3.7\")"
}
