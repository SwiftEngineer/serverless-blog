resource "aws_api_gateway_rest_api" "blog_posts_api" {
  name        = "BlogPostsApi"
  description = "Endpoint for the Serverless Blog application."
}

resource "aws_api_gateway_resource" "blog_posts_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.blog_posts_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.blog_posts_api.root_resource_id}"
  path_part   = "posts"
}

resource "aws_api_gateway_method" "blog_posts_index_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.blog_posts_api.id}"
  resource_id   = "${aws_api_gateway_resource.blog_posts_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

# This integration ties the blog posts lambda to api gateway 
resource "aws_api_gateway_integration" "blog_posts_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.blog_posts_api.id}"
  resource_id = "${aws_api_gateway_method.blog_posts_index_method.resource_id}"
  http_method = "${aws_api_gateway_method.blog_posts_index_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.posts_index.invoke_arn}"
}

# describes the actual deployment of the api gateway service
resource "aws_api_gateway_deployment" "blog_posts_deployment" {
  depends_on = [
    "aws_api_gateway_integration.blog_posts_integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.blog_posts_api.id}"
  stage_name  = "${var.stage}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.posts_index.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.blog_posts_deployment.execution_arn}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.blog_posts_deployment.invoke_url}"
}

// We want AWS to host our zone so its nameservers can point to our CloudFront
// distribution.

// This Route53 record will point at our CloudFront distribution.
resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "${aws_api_gateway_domain_name.api_domain.domain_name}"
  type    = "A"

  alias = {
    name                   = "${aws_api_gateway_domain_name.api_domain.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.api_domain.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "zone" {
  name = "${var.root_domain}"
}

resource "aws_api_gateway_domain_name" "api_domain" {
  domain_name = "${var.subdomain}.${var.root_domain}"

  certificate_arn = "${var.certificate_arn}"
}

resource "aws_api_gateway_base_path_mapping" "test" {
  api_id      = "${aws_api_gateway_rest_api.blog_posts_api.id}"
  stage_name  = "${aws_api_gateway_deployment.blog_posts_deployment.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.api_domain.domain_name}"
}