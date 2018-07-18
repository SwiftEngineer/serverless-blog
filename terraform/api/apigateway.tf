locals {
  url_path_safe_version_number = "${replace(var.api_version, ".", "_")}"
}

# The ApiGateway Rest API to attach the lambdas to.
# This API represents the API as a whole.
# If we wanted to support multiple versions of the app,
# we should create one of these for each version,
# then use a "aws_api_gateway_base_path_mapping" resource
# to map requests to it.
resource "aws_api_gateway_rest_api" "blog_api" {
  name        = "BlogApi"
  description = "Api for the Blog application."
}

# The ApiGateway Resource to handle index requests for BlogPosts.
# If a request hits the API and matches the `path_part`, this 
# resource will attempt to handle it.
resource "aws_api_gateway_resource" "blog_posts_index_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.blog_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.blog_api.root_resource_id}"
  path_part   = "posts"
}

# The ApiGateway Resource to method to handle requests for blog posts
resource "aws_api_gateway_method" "blog_posts_index_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.blog_api.id}"
  resource_id   = "${aws_api_gateway_resource.blog_posts_index_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

# The ApiGateway Resource to handle index requests for BlogPosts.
# If a request hits the API and matches the `path_part`, this 
# resource will attempt to handle it.
resource "aws_api_gateway_resource" "blog_posts_show_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.blog_api.id}"
  parent_id   = "${aws_api_gateway_resource.blog_posts_index_resource.id}"

  # The {postLink} thing you see here is pretty important. 
  # The curly braces make it become a path parameter so that
  # we can use it in our lambda code.
  path_part = "{postLink}"
}

resource "aws_api_gateway_method" "blog_posts_show_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.blog_api.id}"
  resource_id   = "${aws_api_gateway_resource.blog_posts_show_resource.id}"
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.postLink" = true
  }
}

# This integration ties the blog posts index lambda to api gateway 
resource "aws_api_gateway_integration" "blog_posts_index_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.blog_api.id}"
  resource_id = "${aws_api_gateway_method.blog_posts_index_method.resource_id}"
  http_method = "${aws_api_gateway_method.blog_posts_index_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.posts_index.invoke_arn}"
}

# This integration ties the blog posts show lambda to api gateway 
resource "aws_api_gateway_integration" "blog_posts_show_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.blog_api.id}"
  resource_id = "${aws_api_gateway_method.blog_posts_show_method.resource_id}"
  http_method = "${aws_api_gateway_method.blog_posts_show_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.posts_show.invoke_arn}"

  request_parameters {
    "integration.request.path.postLink" = "method.request.path.postLink"
  }
}

# describes the actual deployment of the api gateway service for a given stage
resource "aws_api_gateway_deployment" "blog_posts_deployment" {
  depends_on = [
    "aws_api_gateway_integration.blog_posts_index_integration",
    "aws_api_gateway_integration.blog_posts_show_integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.blog_api.id}"
  stage_name  = "${var.stage}"
}

# permission granted to the "aws_api_gateway_rest_api.blog_api" resource
# that allows it invoke the index lambda
resource "aws_lambda_permission" "api_gateway_deployment_index_lambda_allowance" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.posts_index.arn}"
  principal     = "apigateway.amazonaws.com"

  # The */* portion grants access from any method on any resource,
  # within this deployment.
  #
  # Notice: We don't use the version number here, because we have an
  # API for each version, and this resource only works on one API at
  # a time.
  source_arn = "${aws_api_gateway_deployment.blog_posts_deployment.execution_arn}/*/*"
}

# permission granted to the "aws_api_gateway_rest_api.blog_api" resource
# that allows it invoke the show lambda
resource "aws_lambda_permission" "api_gateway_deployment_show_lambda_allowance" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.posts_show.arn}"
  principal     = "apigateway.amazonaws.com"

  # The */* portion grants access from any method on any resource,
  # within this deployment.
  source_arn = "${aws_api_gateway_deployment.blog_posts_deployment.execution_arn}/*/*"
}

# Api Gateway is gonna lean on cloudfront enable HTTPS. So all
# this route53 record has to do is be an alias for the ApiGateway's
# Cloudfront.
resource "aws_route53_record" "api_cloudfront_alias" {
  # Route 53 zone to place this record in, which was passed into this module
  # from the main.tf file.
  zone_id = "${var.zone_id}"

  name = "${aws_api_gateway_domain_name.api_domain.domain_name}"
  type = "A"

  # IMPORTANT: Notice how we aren't aiming at the UI's cloudfront domain name or zone,
  # we are aiming at the API's domain name.
  alias = {
    name                   = "${aws_api_gateway_domain_name.api_domain.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.api_domain.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

# This `aws_api_gateway_domain_name` does two big things:
#
# 1. It ties our domain name certificate (that one we put in ACM),
#    to the API itself.
#
# 2. It acts as a container to hold each of the path_mappings that
#    will enable us to host different versions of the same API to
#    *help* maintain compatibility with outdated clients.
#
resource "aws_api_gateway_domain_name" "api_domain" {
  domain_name = "${var.subdomain}.${var.root_domain}"

  # certificate arn that was passed down from the main.tf file.
  # this is important as it is shared by both the ui and api.
  certificate_arn = "${var.certificate_arn}"
}

# This `aws_api_gateway_base_path_mapping` is the actual mapping between
# our API's pretty domain name, the version of our api the user wants to use,
# and the actual API itself. It is added to the api's `aws_api_gateway_domain_name`
# alongside any other versions of the api you wish to host.
resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  api_id      = "${aws_api_gateway_rest_api.blog_api.id}"
  stage_name  = "${aws_api_gateway_deployment.blog_posts_deployment.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.api_domain.domain_name}"

  # IMPORTANT: Notice how we have the api version specified here? That's because
  # this `base_path` will be added to the end of our domain name whenever a request is made
  # to our API. 
  base_path = "${local.url_path_safe_version_number}"
}
