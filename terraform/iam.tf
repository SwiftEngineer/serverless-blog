# IAM role for the lambdas
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
}

# IAM role policy with access to dynamo db read only features, attached to lambda policy
resource "aws_iam_role_policy" "blog_posts_dynamo_db_read_only" {
  name = "BlogDynamoReadOnlyDBPolicy"
  role = "${aws_iam_role.blog_posts_lambda_exec.id}"

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Action": "dynamodb:*",
            "Effect": "Allow",
            "Resource": "${aws_dynamodb_table.basic-dynamodb-table.arn}",
            "Sid": ""
        }
    ]
}
EOF
}

# IAM role policy with access to cloudwatch
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
}
