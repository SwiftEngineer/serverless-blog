FROM hashicorp/terraform:0.11.7

COPY . /blog-infrastructure-terraform
WORKDIR /blog-infrastructure-terraform

RUN terraform init

COPY scripts/wait-for-it.sh /usr/local/bin/wait-for-it.sh
COPY scripts/entrypoint.sh /serverless-blog-entrypoint.sh

ENTRYPOINT ["/serverless-blog-entrypoint.sh"]