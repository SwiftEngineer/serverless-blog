# This function handles index requests to fetch all blog posts.
resource "aws_lambda_function" "posts_index" {
  function_name = "BlogPostsIndex"

  # S3 bucket to pull the code from
  s3_bucket = "${aws_s3_bucket.lambda_bucket.id}"

  # Kinda cool that terraform is able to infer dependencies and
  # make sure that this bucket exists and the code is uploaded,
  # before we aim our code at it. This is a big reason why I like
  # to use the `aws_s3_bucket_object` resource.
  s3_key = "${aws_s3_bucket_object.lambda_code.key}"

  # which function to use within the code
  handler = "index.handleIndex"

  # I'm using 6.10 because that's the version that our SAM Local
  # docker image uses. Since that's why I usually aim my e2e tests at,
  # I wanna make sure I'm matching that version of node.
  runtime = "nodejs6.10"

  # If you were curious how the lambda was able to use DynamoDB,
  # this is how. Not to mention lambdas need a few permissions just to
  # operate, let along make requests to other services.
  role = "${aws_iam_role.blog_posts_lambda_exec.arn}"

  environment = {
    variables {
      # Used to set the `Allow-Access-Control-Origin` header on the request.
      # Just in the case the API url is different from the website url,
      # this should let is get around the same-origin policy.
      ALLOWED_ORIGIN = "https://${var.website_subdomain}.${var.root_domain}"
    }
  }

  # Tags to track costs
  tags = {
    Project     = "${var.website_subdomain}.${var.root_domain}"
    ServiceType = "api"
    Version     = "${var.api_version}"
  }
}

# Sometimes the user will just want 1 blog post, which they will fetch by id.
# That's what this guy does.
resource "aws_lambda_function" "posts_show" {
  function_name = "BlogPostsShow"

  # S3 Bucket we are pulling the code from, same as above
  s3_bucket = "${aws_s3_bucket.lambda_bucket.id}"
  s3_key    = "${aws_s3_bucket_object.lambda_code.key}"

  # which function to use within the code
  handler = "index.handleShow"

  # I'm using 6.10 because that's the version that our SAM Local
  # docker image uses. Since that's why I usually aim my e2e tests at,
  # I wanna make sure I'm matching that version of node.
  runtime = "nodejs6.10"

  # If you were curious how the lambda was able to use DynamoDB,
  # this is how. Not to mention lambdas need a few permissions just to
  # operate, let along make requests to other services.
  role = "${aws_iam_role.blog_posts_lambda_exec.arn}"

  environment = {
    variables {
      # Used to set the `Allow-Access-Control-Origin` header on the request.
      # Just in the case the API url is different from the website url,
      # this should let is get around the same-origin policy.
      ALLOWED_ORIGIN = "https://${var.website_subdomain}.${var.root_domain}"
    }
  }

  # Tags to track costs
  tags = {
    Project     = "${var.website_subdomain}.${var.root_domain}"
    ServiceType = "api"
    Version     = "${var.api_version}"
  }
}

resource "aws_s3_bucket" "lambda_bucket" {
  # name of the bucket we're gonna but all the code into
  bucket = "l33t-h4x-for-${var.subdomain}.${var.root_domain}"

  # Makes the website public to any services that use ACLs to view content
  acl = "public-read"

  # when we want to clean up the website (i.e. when we run terraform destroy)
  # we want to remove the s3 bucket, regardless of the fact that it has objects in it
  force_destroy = true

  # Since this bucket will contain all the versions of the api code,
  # we don't tag it with a version.
  tags = {
    Project     = "${var.website_subdomain}.${var.root_domain}"
    ServiceType = "api"
  }
}

# The entire code base is all in one zip file, which is fine for a tiny project like this,
# but I would definitely recommend you split things up into multiple files if you wanna
# scale this kind of architecture. If you've been reading all these comments, I doubt
# you'll have any trouble doing it.
resource "aws_s3_bucket_object" "lambda_code" {
  # because of the version key, we are going to make sure not to 
  # override existing versions of the app
  key = "${var.api_version}/api.zip"

  # Bucket the code is gonna go into
  bucket = "${aws_s3_bucket.lambda_bucket.id}"
  source = "/lambda_ready_app/api.zip"

  # Tags to track costs
  tags = {
    Project     = "${var.website_subdomain}.${var.root_domain}"
    ServiceType = "api"
    Version     = "${var.api_version}"
  }
}
