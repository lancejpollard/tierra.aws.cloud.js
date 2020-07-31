
provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "paris" {
  cidr_block = "10.8.0.0/16"
}

resource "aws_lb" "lb" {
  name = "paris"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
    aws_subnet.paris_eu_west_3a_gateway.id,
    aws_subnet.paris_eu_west_3b_gateway.id,
    aws_subnet.paris_eu_west_3c_gateway.id
  ]
  enable_http2 = true
}

resource "aws_security_group" "https" {
  name = "paris"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = aws_vpc.paris.id
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.8.0.0/21",
      "10.8.24.0/21",
      "10.8.48.0/21"
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

resource "aws_subnet" "paris_eu_west_3a_gateway" {
  vpc_id = aws_vpc.paris.id
  cidr_block = "10.8.0.0/21"
  availability_zone = "eu-west-3a"
}

resource "aws_subnet" "paris_eu_west_3a_compute" {
  vpc_id = aws_vpc.paris.id
  cidr_block = "10.8.8.0/21"
  availability_zone = "eu-west-3a"
}

resource "aws_subnet" "paris_eu_west_3a_storage" {
  vpc_id = aws_vpc.paris.id
  cidr_block = "10.8.16.0/21"
  availability_zone = "eu-west-3a"
}

resource "aws_subnet" "paris_eu_west_3b_gateway" {
  vpc_id = aws_vpc.paris.id
  cidr_block = "10.8.24.0/21"
  availability_zone = "eu-west-3b"
}

resource "aws_subnet" "paris_eu_west_3b_compute" {
  vpc_id = aws_vpc.paris.id
  cidr_block = "10.8.32.0/21"
  availability_zone = "eu-west-3b"
}

resource "aws_subnet" "paris_eu_west_3b_storage" {
  vpc_id = aws_vpc.paris.id
  cidr_block = "10.8.40.0/21"
  availability_zone = "eu-west-3b"
}

resource "aws_subnet" "paris_eu_west_3c_gateway" {
  vpc_id = aws_vpc.paris.id
  cidr_block = "10.8.48.0/21"
  availability_zone = "eu-west-3c"
}

resource "aws_subnet" "paris_eu_west_3c_compute" {
  vpc_id = aws_vpc.paris.id
  cidr_block = "10.8.56.0/21"
  availability_zone = "eu-west-3c"
}

resource "aws_subnet" "paris_eu_west_3c_storage" {
  vpc_id = aws_vpc.paris.id
  cidr_block = "10.8.64.0/21"
  availability_zone = "eu-west-3c"
}

output "lb_arn" {
  value = aws_lb.lb.arn
}