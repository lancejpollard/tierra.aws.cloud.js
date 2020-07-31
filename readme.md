
```hcl
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "us-west-1"
  version = "~> 2.70"
}

module "cloud" {
  source = "../cloud"
  domain = "example.com"
}
```
