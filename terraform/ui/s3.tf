# This s3 bucket exists purely to serve the assets for the website to
# the cloudfront distro. You could host a website outside of AWS if
# you wish too (and then point cloudfront at that domain), but I have
# always loved how easy it is to serve content from S3, so that's what
# I went with for this project.
resource "aws_s3_bucket" "client_source" {
  # Since we are making this website available to cloudfront via
  # S3's static hosting, we could name it pretty much anything we want,
  # as long as it is URI friendly.
  #
  # That being said, I like to name my website source buckets the same
  # as the cloudfront domain they provide assets to, so that's what I'm
  # doing here.
  bucket = "${var.subdomain}.${var.root_domain}"

  # Makes the website public to any services that use ACLs to view content,
  # Since cloudfront is using a role, you could turn this off if you wish,
  # but since I WANT anyone to be able to look at the content of this bucket,
  # I'm just gonna open it to everyone.
  acl = "public-read"

  # This option informs terraform that when we want to destroy the website
  # (i.e. when we run `terraform destroy`), terraform should attempt
  # remove the s3 bucket, regardless of the fact that it has objects in it.
  force_destroy = true

  # Configure hosting properties of the website
  website {
    # This is the key of the object we will show to anyone accessing the service
    # through the url directly. This only exists to allow users to access the
    # bucket DIRECTLY through S3 Static Hosting, rather than through CloudFront.
    #
    # If you want to only host through CloudFront, you could remove this.
    index_document = "index.html"

    # Key of the object that we will show when anyone tries to access
    # this S3 bucket directly though S3 Static Hosting and something
    # goes wrong.
    error_document = "error.html"
  }

  # Tags to track costs.
  tags = {
    Project     = "${var.subdomain}.${var.root_domain}"
    ServiceType = "ui"
  }

  # Makes the website public to more modern services, like CloudFront for
  # instance. If you wanted to ONLY allow cloudfront to fetch objects
  # from the bucket, you could set the "Principal" of this policy accordingly.
  # Again though, I wanna keep this bucket as open as possible.
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
}

####
##
##  !!!!!!!!!!!!!!!!!!    TRIGGER WARNING    !!!!!!!!!!!!!!!!!!
##
##  Everthing below here is kind of a hack job in my opinion.
##
##  Normally I would use a CI/CD pipeline to push assets
##  into the S3 bucket after tests have passed and QA signed
##  off on a release.
##
##  However, I don't have a CI/CD pipeline for this project.
##  
##  So instead I just created a terraform resource for each
##  file inside the a volume (folder) that I will mount onto
##  the Docker container that does all this terraform stuff
##  for me. That way at least I can keep things containerized
##  for when I finally pony up the cash/time to get a service
##  like Codeship, CircleCI, or TravisCI integrated.
##
###

resource "aws_s3_bucket_object" "index_html" {
  key    = "index.html"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "/s3_ready_app/index.html"

  # pro tip if you do end up using this hacky solution:
  # make sure to set the content type of things.
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "error_html" {
  key    = "error.html"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "./ui/error.html"

  content_type = "text/html"
}

resource "aws_s3_bucket_object" "maface_img" {
  key    = "img/maface.jpg"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "/s3_ready_app/img/maface.jpg"
}

resource "aws_s3_bucket_object" "parallax_img" {
  key    = "img/parallax.svg"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "/s3_ready_app/img/parallax.svg"

  content_type = "image/svg+xml"
}

resource "aws_s3_bucket_object" "css" {
  key    = "static/css/main.css"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "/s3_ready_app/static/css/main.css"

  content_type = "text/css"
}

resource "aws_s3_bucket_object" "nucleo_outline_eot" {
  key    = "static/fonts/nucleo-outline.eot"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "/s3_ready_app/static/fonts/nucleo-outline.eot"
}

resource "aws_s3_bucket_object" "nucleo_outline_ttf" {
  key    = "static/fonts/nucleo-outline.ttf"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "/s3_ready_app/static/fonts/nucleo-outline.ttf"
}

resource "aws_s3_bucket_object" "nucleo_outline_woff" {
  key    = "static/fonts/nucleo-outline.woff"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "/s3_ready_app/static/fonts/nucleo-outline.woff"
}

resource "aws_s3_bucket_object" "nucleo_outline_woff2" {
  key    = "static/fonts/nucleo-outline.woff2"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "/s3_ready_app/static/fonts/nucleo-outline.woff2"
}

resource "aws_s3_bucket_object" "js" {
  key    = "static/js/main.js"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "/s3_ready_app/static/js/main.js"
}

resource "aws_s3_bucket_object" "favicon" {
  key    = "favicon.ico"
  bucket = "${aws_s3_bucket.client_source.id}"
  source = "/s3_ready_app/favicon.ico"
}
