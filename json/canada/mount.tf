
provider "aws" {
  region = "ca-central-1"
}

resource "aws_vpc" "canada" {
  cidr_block = "10.16.0.0/16"
}

resource "aws_lb" "lb" {
  name = "canada"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
    aws_subnet.canada_ca_central_1a_gateway.id,
    aws_subnet.canada_ca_central_1b_gateway.id,
    aws_subnet.canada_ca_central_1d_gateway.id
  ]
  enable_http2 = true
}

resource "aws_security_group" "https" {
  name = "canada"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = aws_vpc.canada.id
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.16.0.0/21",
      "10.16.24.0/21",
      "10.16.48.0/21"
    ]
  }
  egress {
    description = "Outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "canada_ca_central_1a_gateway" {
  vpc_id = aws_vpc.canada.id
  cidr_block = "10.16.0.0/21"
  availability_zone = "ca-central-1a"
}

resource "aws_subnet" "canada_ca_central_1a_compute" {
  vpc_id = aws_vpc.canada.id
  cidr_block = "10.16.8.0/21"
  availability_zone = "ca-central-1a"
}

resource "aws_subnet" "canada_ca_central_1a_storage" {
  vpc_id = aws_vpc.canada.id
  cidr_block = "10.16.16.0/21"
  availability_zone = "ca-central-1a"
}

resource "aws_subnet" "canada_ca_central_1b_gateway" {
  vpc_id = aws_vpc.canada.id
  cidr_block = "10.16.24.0/21"
  availability_zone = "ca-central-1b"
}

resource "aws_subnet" "canada_ca_central_1b_compute" {
  vpc_id = aws_vpc.canada.id
  cidr_block = "10.16.32.0/21"
  availability_zone = "ca-central-1b"
}

resource "aws_subnet" "canada_ca_central_1b_storage" {
  vpc_id = aws_vpc.canada.id
  cidr_block = "10.16.40.0/21"
  availability_zone = "ca-central-1b"
}

resource "aws_subnet" "canada_ca_central_1d_gateway" {
  vpc_id = aws_vpc.canada.id
  cidr_block = "10.16.48.0/21"
  availability_zone = "ca-central-1d"
}

resource "aws_subnet" "canada_ca_central_1d_compute" {
  vpc_id = aws_vpc.canada.id
  cidr_block = "10.16.56.0/21"
  availability_zone = "ca-central-1d"
}

resource "aws_subnet" "canada_ca_central_1d_storage" {
  vpc_id = aws_vpc.canada.id
  cidr_block = "10.16.64.0/21"
  availability_zone = "ca-central-1d"
}

output "lb_arn" {
  value = aws_lb.lb.arn
}