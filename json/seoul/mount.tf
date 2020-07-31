
provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "seoul" {
  cidr_block = "10.11.0.0/16"
}

resource "aws_lb" "lb" {
  name = "seoul"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
    aws_subnet.seoul_ap_northeast_2a_gateway.id,
    aws_subnet.seoul_ap_northeast_2b_gateway.id,
    aws_subnet.seoul_ap_northeast_2c_gateway.id,
    aws_subnet.seoul_ap_northeast_2d_gateway.id
  ]
  enable_http2 = true
}

resource "aws_security_group" "https" {
  name = "seoul"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = aws_vpc.seoul.id
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.11.0.0/21",
      "10.11.24.0/21",
      "10.11.48.0/21"
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

resource "aws_subnet" "seoul_ap_northeast_2a_gateway" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.0.0/21"
  availability_zone = "ap-northeast-2a"
}

resource "aws_subnet" "seoul_ap_northeast_2a_compute" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.8.0/21"
  availability_zone = "ap-northeast-2a"
}

resource "aws_subnet" "seoul_ap_northeast_2a_storage" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.16.0/21"
  availability_zone = "ap-northeast-2a"
}

resource "aws_subnet" "seoul_ap_northeast_2b_gateway" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.24.0/21"
  availability_zone = "ap-northeast-2b"
}

resource "aws_subnet" "seoul_ap_northeast_2b_compute" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.32.0/21"
  availability_zone = "ap-northeast-2b"
}

resource "aws_subnet" "seoul_ap_northeast_2b_storage" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.40.0/21"
  availability_zone = "ap-northeast-2b"
}

resource "aws_subnet" "seoul_ap_northeast_2c_gateway" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.48.0/21"
  availability_zone = "ap-northeast-2c"
}

resource "aws_subnet" "seoul_ap_northeast_2c_compute" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.56.0/21"
  availability_zone = "ap-northeast-2c"
}

resource "aws_subnet" "seoul_ap_northeast_2c_storage" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.64.0/21"
  availability_zone = "ap-northeast-2c"
}

resource "aws_subnet" "seoul_ap_northeast_2d_gateway" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.72.0/21"
  availability_zone = "ap-northeast-2d"
}

resource "aws_subnet" "seoul_ap_northeast_2d_compute" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.80.0/21"
  availability_zone = "ap-northeast-2d"
}

resource "aws_subnet" "seoul_ap_northeast_2d_storage" {
  vpc_id = aws_vpc.seoul.id
  cidr_block = "10.11.88.0/21"
  availability_zone = "ap-northeast-2d"
}

output "lb_arn" {
  value = aws_lb.lb.arn
}