
variable "enabled" {
  description = "Whether this is enabled or not."
  type = bool
  default = false
}

variable "vpc_id" {
  description = "Region VPC ID"
  type = string
}

variable "region" {
  description = "The human region name"
  type = string
}

variable "region_code" {
  description = "The AWS region"
  type = string
}

variable "gateway" {
  description = "Availability Zone Info for Gateway"
  type = object({
    cidr_block = string,
    availability_zone = string
  })
}

variable "compute" {
  description = "Availability Zone Info for Compute"
  type = object({
    cidr_block = string,
    availability_zone = string
  })
}

variable "storage" {
  description = "Availability Zone Info for Storage"
  type = object({
    cidr_block = string,
    availability_zone = string
  })
}

locals {
  gateway_cidr_block = concat(aws_subnet.gateway.*.cidr_block, [""])[0]
  gateway_subnet_id = concat(aws_subnet.gateway.*.id, [""])[0]
}

provider "aws" {
  region = var.region_code
}

resource "aws_subnet" "gateway" {
  count = var.enabled ? 1 : 0
  vpc_id = var.vpc_id
  cidr_block = var.gateway.cidr_block
  availability_zone = var.gateway.availability_zone

  tags = {
    name = format(
      "subnet-gateway-%s-%s",
      var.region,
      var.gateway.availability_zone
    )
  }
}

resource "aws_subnet" "compute" {
  count = var.enabled ? 1 : 0
  vpc_id = var.vpc_id
  cidr_block = var.compute.cidr_block
  availability_zone = var.compute.availability_zone

  tags = {
    name = format(
      "subnet-compute-%s-%s",
      var.region,
      var.compute.availability_zone
    )
  }
}

resource "aws_subnet" "storage" {
  count = var.enabled ? 1 : 0
  vpc_id = var.vpc_id
  cidr_block = var.storage.cidr_block
  availability_zone = var.storage.availability_zone

  tags = {
    name = format(
      "subnet-storage-%s-%s",
      var.region,
      var.storage.availability_zone
    )
  }
}

output "gateway_cidr_block" {
  value = local.gateway_cidr_block
}

output "gateway_subnet_id" {
  value = local.gateway_subnet_id
}
