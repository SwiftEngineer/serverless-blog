resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Posts"
  read_capacity  = 25
  write_capacity = 25
  hash_key       = "Link"

  attribute {
    name = "Link"
    type = "S"
  }

  tags {
    Name        = "blog-post-api-dynamodb-table"
    Environment = "${var.stage}"
  }
}
