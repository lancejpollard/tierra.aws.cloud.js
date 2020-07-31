
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "us-west-1"
}

module "check" {
  source = "./check"
  environment = "check"
}

module "front" {
  source = "./front"
  environment = "front"
}