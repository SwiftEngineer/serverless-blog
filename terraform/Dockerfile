FROM hashicorp/terraform:0.11.7

COPY . /blog-infrastructure-terraform
WORKDIR /blog-infrastructure-terraform

COPY scripts/wait-for-it.sh /usr/local/bin/wait-for-it.sh

RUN terraform init

ENTRYPOINT ["wait-for-it.sh", "api:3000", "--", "terraform"]
CMD ["apply"]