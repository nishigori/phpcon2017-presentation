provider "aws" {
  # https://github.com/terraform-providers/terraform-provider-aws/releases
  version = "~> 1.0.0"
  region  = "${var.region}"
}

provider "template" {
  # https://github.com/terraform-providers/terraform-provider-template/releases
  version = "~> 1.0.0"
}
