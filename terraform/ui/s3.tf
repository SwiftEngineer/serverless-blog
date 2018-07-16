resource "aws_s3_bucket" "www" {
  // Bucket names must match the domain name, according to AWS
  bucket = "${var.subdomain}.${var.root_domain}"

  // Makes the website public to any services that use ACLs to view content
  acl = "public-read"

  // when we want to clean up the website (i.e. when we run terraform destroy)
  // we want to remove the s3 bucket, regardless of the fact that it has objects in it
  force_destroy = true

  // Makes the website public to any services that are on that new shit
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.subdomain}.${var.root_domain}/*"]
    }
  ]
}
POLICY

  // Configure hosting properties of the website
  website {
    // This is the field AWS will present to any service asking for the website
    index_document = "index.html"

    // This is the field AWS will present to any service asking for the website
    // if something goes wrong
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "maface_img" {
  key    = "img/maface.jpg"
  bucket = "${aws_s3_bucket.www.id}"
  source = "/s3_ready_app/img/maface.jpg"
}

resource "aws_s3_bucket_object" "parallax_img" {
  key    = "img/parallax.svg"
  bucket = "${aws_s3_bucket.www.id}"
  source = "/s3_ready_app/img/parallax.svg"

  content_type = "image/svg+xml"
}

resource "aws_s3_bucket_object" "css" {
  key    = "static/css/main.css"
  bucket = "${aws_s3_bucket.www.id}"
  source = "/s3_ready_app/static/css/main.css"

  content_type = "text/css"
}

resource "aws_s3_bucket_object" "nucleo_outline_eot" {
  key    = "static/fonts/nucleo-outline.eot"
  bucket = "${aws_s3_bucket.www.id}"
  source = "/s3_ready_app/static/fonts/nucleo-outline.eot"
}

resource "aws_s3_bucket_object" "nucleo_outline_ttf" {
  key    = "static/fonts/nucleo-outline.ttf"
  bucket = "${aws_s3_bucket.www.id}"
  source = "/s3_ready_app/static/fonts/nucleo-outline.ttf"
}

resource "aws_s3_bucket_object" "nucleo_outline_woff" {
  key    = "static/fonts/nucleo-outline.woff"
  bucket = "${aws_s3_bucket.www.id}"
  source = "/s3_ready_app/static/fonts/nucleo-outline.woff"
}

resource "aws_s3_bucket_object" "nucleo_outline_woff2" {
  key    = "static/fonts/nucleo-outline.woff2"
  bucket = "${aws_s3_bucket.www.id}"
  source = "/s3_ready_app/static/fonts/nucleo-outline.woff2"
}

resource "aws_s3_bucket_object" "js" {
  key    = "static/js/main.js"
  bucket = "${aws_s3_bucket.www.id}"
  source = "/s3_ready_app/static/js/main.js"
}

resource "aws_s3_bucket_object" "favicon" {
  key    = "favicon.ico"
  bucket = "${aws_s3_bucket.www.id}"
  source = "/s3_ready_app/favicon.ico"
}

resource "aws_s3_bucket_object" "index_html" {
  key    = "index.html"
  bucket = "${aws_s3_bucket.www.id}"
  source = "/s3_ready_app/index.html"

  content_type = "text/html"
}
