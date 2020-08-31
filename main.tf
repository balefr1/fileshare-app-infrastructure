# https://www.terraform.io/downloads.html

terraform {
}

provider "aws" {
    region = var.region
    profile = "default"
}

//get account id
data "aws_caller_identity" "current" {}

