resource "aws_lambda_function" "posts_index" {
  function_name = "BlogPostsIndex"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "${aws_s3_bucket.lambda_bucket.id}"
  s3_key    = "${aws_s3_bucket_object.lambda_code.key}"

  # which function to use within the entire codebase
  handler = "index.handleIndex"
  runtime = "nodejs6.10"

  role = "${aws_iam_role.blog_posts_lambda_exec.arn}"
}

resource "aws_s3_bucket" "lambda_bucket" {
  // name of the bucket
  bucket = "l33t-h4x-for-${var.subdomain}.${var.root_domain}"

  // Makes the website public to any services that use ACLs to view content
  acl = "public-read"

  // when we want to clean up the website (i.e. when we run terraform destroy)
  // we want to remove the s3 bucket, regardless of the fact that it has objects in it
  force_destroy = true
}

resource "aws_s3_bucket_object" "lambda_code" {
  key    = "api.zip"
  bucket = "${aws_s3_bucket.lambda_bucket.id}"
  source = "/lambda_ready_app/api.zip"
}
