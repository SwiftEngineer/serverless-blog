resource "aws_s3_bucket" "www" {
  // Bucket names must match the domain name, according to AWS
  bucket = "${var.subdomain}.${var.root_domain}"

  // Makes the website public to any services that use ACLs to view content
  acl = "public-read"

  // when we want to clean up the website (i.e. when we run terraform destroy)
  // we want to remove the s3 bucket, regardless of the fact that it has objects in it
  force_destroy = true

  // Makes the website public to any services that are on that new shit
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

  // Configure hosting properties of the website
  website {
    // This is the field AWS will present to any service asking for the website
    index_document = "index.html"

    // This is the field AWS will present to any service asking for the website
    // if something goes wrong
    error_document = "error.html"
  }
}
