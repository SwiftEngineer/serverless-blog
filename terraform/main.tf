module "api" {
  source = "./api"

  aws_secret_key_id = "${var.aws_secret_key_id}"

  aws_secret_key = "${var.aws_secret_key}"

  aws_region = "${var.aws_region}"

  stage = "${var.stage}"

  subdomain = "${var.subdomain}"

  root_domain = "${var.root_domain}"
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

