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

variable "api_subdomain" {
  description = "The subdomain used to access the api for the website. (examples: \"api-for\", \"www\", \"kanyewest\", \"iam\"...)"
}

variable "root_domain" {
  description = "You may know it as the zone apex or naked domain (examples: \"doyouknowtheway.com\", \"bestartist.net\", \"so.cool\"...)"
}

variable "api_version" {
  description = "Version of the api to deploy. Other versions' code will remain in S3, but will no longer be used to handle requests. (examples: \"1.0.0\", \"0.1.2\", \"1.3.7\")"
}

variable "ui_version" {
  description = "Version of the ui to deploy. Other versions' code will remain in S3, but will no longer be served to clients. (examples: \"1.0.0\", \"0.1.2\", \"1.3.7\")"
}
