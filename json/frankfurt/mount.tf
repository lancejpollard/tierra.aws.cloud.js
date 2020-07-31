
provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "frankfurt" {
  cidr_block = "10.5.0.0/16"
}

resource "aws_lb" "lb" {
  name = "frankfurt"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
    aws_subnet.frankfurt_eu_central_1a_gateway.id,
    aws_subnet.frankfurt_eu_central_1b_gateway.id,
    aws_subnet.frankfurt_eu_central_1c_gateway.id
  ]
  enable_http2 = true
}

resource "aws_security_group" "https" {
  name = "frankfurt"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = aws_vpc.frankfurt.id
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.5.0.0/21",
      "10.5.24.0/21",
      "10.5.48.0/21"
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

resource "aws_subnet" "frankfurt_eu_central_1a_gateway" {
  vpc_id = aws_vpc.frankfurt.id
  cidr_block = "10.5.0.0/21"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "frankfurt_eu_central_1a_compute" {
  vpc_id = aws_vpc.frankfurt.id
  cidr_block = "10.5.8.0/21"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "frankfurt_eu_central_1a_storage" {
  vpc_id = aws_vpc.frankfurt.id
  cidr_block = "10.5.16.0/21"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "frankfurt_eu_central_1b_gateway" {
  vpc_id = aws_vpc.frankfurt.id
  cidr_block = "10.5.24.0/21"
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "frankfurt_eu_central_1b_compute" {
  vpc_id = aws_vpc.frankfurt.id
  cidr_block = "10.5.32.0/21"
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "frankfurt_eu_central_1b_storage" {
  vpc_id = aws_vpc.frankfurt.id
  cidr_block = "10.5.40.0/21"
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "frankfurt_eu_central_1c_gateway" {
  vpc_id = aws_vpc.frankfurt.id
  cidr_block = "10.5.48.0/21"
  availability_zone = "eu-central-1c"
}

resource "aws_subnet" "frankfurt_eu_central_1c_compute" {
  vpc_id = aws_vpc.frankfurt.id
  cidr_block = "10.5.56.0/21"
  availability_zone = "eu-central-1c"
}

resource "aws_subnet" "frankfurt_eu_central_1c_storage" {
  vpc_id = aws_vpc.frankfurt.id
  cidr_block = "10.5.64.0/21"
  availability_zone = "eu-central-1c"
}

output "lb_arn" {
  value = aws_lb.lb.arn
}