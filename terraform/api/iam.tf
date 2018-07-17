# Base IAM role to be used by the lambda functions
resource "aws_iam_role" "blog_posts_lambda_exec" {
  name = "BlogLambdaPolicy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  # Tags to track costs
  tags = {
    Project     = "${var.website_subdomain}.${var.root_domain}"
    ServiceType = "api"
  }
}

# IAM role policy with access to dynamo db read only features,
# it's attached to the above lambda policy
resource "aws_iam_role_policy" "blog_posts_dynamo_db_read_only" {
  name = "BlogDynamoReadOnlyDBPolicy"

  # this is how we attach a policy to a role
  role = "${aws_iam_role.blog_posts_lambda_exec.id}"

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Action": "dynamodb:*",
            "Effect": "Allow",
            "Resource": "${aws_dynamodb_table.basic_dynamodb_table.arn}",
            "Sid": ""
        }
    ]
}
EOF

  # Tags to track costs
  tags = {
    Project     = "${var.website_subdomain}.${var.root_domain}"
    ServiceType = "api"
  }
}

# IAM role policy with access to log creation in cloudwatch,
# because we like logs.
# it's attached to the above lambda policy.
resource "aws_iam_role_policy" "cloud_watch" {
  name = "BlogCloudWatchLoggingPolicy"

  role = "${aws_iam_role.blog_posts_lambda_exec.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF

  # Tags to track costs
  tags = {
    Project     = "${var.website_subdomain}.${var.root_domain}"
    ServiceType = "api"
  }
}
