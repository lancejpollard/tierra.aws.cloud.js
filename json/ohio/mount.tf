
provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "ohio" {
  cidr_block = "10.3.0.0/16"
}

resource "aws_lb" "lb" {
  name = "ohio"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
    aws_subnet.ohio_us_east_2a_gateway.id,
    aws_subnet.ohio_us_east_2b_gateway.id,
    aws_subnet.ohio_us_east_2c_gateway.id
  ]
  enable_http2 = true
}

resource "aws_security_group" "https" {
  name = "ohio"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = aws_vpc.ohio.id
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.3.0.0/21",
      "10.3.24.0/21",
      "10.3.48.0/21"
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

resource "aws_subnet" "ohio_us_east_2a_gateway" {
  vpc_id = aws_vpc.ohio.id
  cidr_block = "10.3.0.0/21"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "ohio_us_east_2a_compute" {
  vpc_id = aws_vpc.ohio.id
  cidr_block = "10.3.8.0/21"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "ohio_us_east_2a_storage" {
  vpc_id = aws_vpc.ohio.id
  cidr_block = "10.3.16.0/21"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "ohio_us_east_2b_gateway" {
  vpc_id = aws_vpc.ohio.id
  cidr_block = "10.3.24.0/21"
  availability_zone = "us-east-2b"
}

resource "aws_subnet" "ohio_us_east_2b_compute" {
  vpc_id = aws_vpc.ohio.id
  cidr_block = "10.3.32.0/21"
  availability_zone = "us-east-2b"
}

resource "aws_subnet" "ohio_us_east_2b_storage" {
  vpc_id = aws_vpc.ohio.id
  cidr_block = "10.3.40.0/21"
  availability_zone = "us-east-2b"
}

resource "aws_subnet" "ohio_us_east_2c_gateway" {
  vpc_id = aws_vpc.ohio.id
  cidr_block = "10.3.48.0/21"
  availability_zone = "us-east-2c"
}

resource "aws_subnet" "ohio_us_east_2c_compute" {
  vpc_id = aws_vpc.ohio.id
  cidr_block = "10.3.56.0/21"
  availability_zone = "us-east-2c"
}

resource "aws_subnet" "ohio_us_east_2c_storage" {
  vpc_id = aws_vpc.ohio.id
  cidr_block = "10.3.64.0/21"
  availability_zone = "us-east-2c"
}

output "lb_arn" {
  value = aws_lb.lb.arn
}