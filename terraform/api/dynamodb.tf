# This is the dynamoDB table that the blog posts will be uploaded to.
# 
# It should be noted that I spent pretty much 0 time creating the schema
# and queries for get this whole API working, so it's pretty crap. So if
# you want to create your own DynamoDB table and are using my code as a
# guideline, please for the love of Linus Torvald's stop. Spend time learning
# about NoSQL schema design. AWS has some awesome guides on it, and if I ever
# get off my lazy butt I'll make a guide myself for how to do this kind of thing
# the "right" way.
#
# TL;DR Using DynamoDB the "right" way is out of scope, so don't do what I did here.
#
resource "aws_dynamodb_table" "basic_dynamodb_table" {
  name = "Posts"

  # 25 read / 25 write is just at the edge of the
  # free tier according to https://aws.amazon.com/dynamodb/pricing/ .
  # If you have other services on DynamoDB and want to conserve
  # resources, check out https://www.terraform.io/docs/providers/aws/r/api_gateway_base_path_mapping.html
  read_capacity = 25

  write_capacity = 25

  # If you come from a SQL database background, this
  # "Link" attribute is basically my primary key. 
  # Other attributes are added dynamically with no set schema.
  hash_key = "Link"

  # actual attribute definition itself
  attribute {
    name = "Link" # Field name
    type = "S"    # Type, in this case a String
  }

  # Tags to track costs
  tags = {
    Project     = "${var.website_subdomain}.${var.root_domain}"
    ServiceType = "api"
  }
}
