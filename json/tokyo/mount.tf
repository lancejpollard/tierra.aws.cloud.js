
provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "tokyo" {
  cidr_block = "10.14.0.0/16"
}

resource "aws_lb" "lb" {
  name = "tokyo"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
    aws_subnet.tokyo_ap_northeast_1a_gateway.id,
    aws_subnet.tokyo_ap_northeast_1c_gateway.id,
    aws_subnet.tokyo_ap_northeast_1d_gateway.id
  ]
  enable_http2 = true
}

resource "aws_security_group" "https" {
  name = "tokyo"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = aws_vpc.tokyo.id
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.14.0.0/21",
      "10.14.24.0/21",
      "10.14.48.0/21"
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

resource "aws_subnet" "tokyo_ap_northeast_1a_gateway" {
  vpc_id = aws_vpc.tokyo.id
  cidr_block = "10.14.0.0/21"
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "tokyo_ap_northeast_1a_compute" {
  vpc_id = aws_vpc.tokyo.id
  cidr_block = "10.14.8.0/21"
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "tokyo_ap_northeast_1a_storage" {
  vpc_id = aws_vpc.tokyo.id
  cidr_block = "10.14.16.0/21"
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "tokyo_ap_northeast_1c_gateway" {
  vpc_id = aws_vpc.tokyo.id
  cidr_block = "10.14.24.0/21"
  availability_zone = "ap-northeast-1c"
}

resource "aws_subnet" "tokyo_ap_northeast_1c_compute" {
  vpc_id = aws_vpc.tokyo.id
  cidr_block = "10.14.32.0/21"
  availability_zone = "ap-northeast-1c"
}

resource "aws_subnet" "tokyo_ap_northeast_1c_storage" {
  vpc_id = aws_vpc.tokyo.id
  cidr_block = "10.14.40.0/21"
  availability_zone = "ap-northeast-1c"
}

resource "aws_subnet" "tokyo_ap_northeast_1d_gateway" {
  vpc_id = aws_vpc.tokyo.id
  cidr_block = "10.14.48.0/21"
  availability_zone = "ap-northeast-1d"
}

resource "aws_subnet" "tokyo_ap_northeast_1d_compute" {
  vpc_id = aws_vpc.tokyo.id
  cidr_block = "10.14.56.0/21"
  availability_zone = "ap-northeast-1d"
}

resource "aws_subnet" "tokyo_ap_northeast_1d_storage" {
  vpc_id = aws_vpc.tokyo.id
  cidr_block = "10.14.64.0/21"
  availability_zone = "ap-northeast-1d"
}

output "lb_arn" {
  value = aws_lb.lb.arn
}