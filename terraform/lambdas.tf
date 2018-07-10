provider "aws" {
  access_key = "${var.aws_secret_key_id}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_lambda_function" "posts_index" {
  function_name = "BlogPostsIndex"

  # The code for the lambda
  filename = "dist/api.zip"

  # which function to use within the entire codebase
  handler = "index.handleIndex"
  runtime = "nodejs8.10"

  role = "${aws_iam_role.blog_posts_lambda_exec.arn}"
}
