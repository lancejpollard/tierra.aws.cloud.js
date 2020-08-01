
terraform {
  required_version = ">= 0.12"
  
  required_providers {
    aws = "~> 3.0.0"
  }
}

provider "aws" {
  region = "us-west-1"
}

module "check" {
  environment = "check"
  source = "./check"
}

module "front" {
  environment = "front"
  source = "./front"
}
