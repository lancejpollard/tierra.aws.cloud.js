
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "virginia" {
  cidr_block = "10.4.0.0/16"
}

resource "aws_lb" "lb" {
  name = "virginia"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
    aws_subnet.virginia_us_east_1a_gateway.id,
    aws_subnet.virginia_us_east_1b_gateway.id,
    aws_subnet.virginia_us_east_1c_gateway.id,
    aws_subnet.virginia_us_east_1d_gateway.id,
    aws_subnet.virginia_us_east_1e_gateway.id,
    aws_subnet.virginia_us_east_1f_gateway.id
  ]
  enable_http2 = true
}

resource "aws_security_group" "https" {
  name = "virginia"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = aws_vpc.virginia.id
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.4.0.0/21",
      "10.4.24.0/21",
      "10.4.48.0/21"
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

resource "aws_subnet" "virginia_us_east_1a_gateway" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.0.0/21"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "virginia_us_east_1a_compute" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.8.0/21"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "virginia_us_east_1a_storage" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.16.0/21"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "virginia_us_east_1b_gateway" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.24.0/21"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "virginia_us_east_1b_compute" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.32.0/21"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "virginia_us_east_1b_storage" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.40.0/21"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "virginia_us_east_1c_gateway" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.48.0/21"
  availability_zone = "us-east-1c"
}

resource "aws_subnet" "virginia_us_east_1c_compute" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.56.0/21"
  availability_zone = "us-east-1c"
}

resource "aws_subnet" "virginia_us_east_1c_storage" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.64.0/21"
  availability_zone = "us-east-1c"
}

resource "aws_subnet" "virginia_us_east_1d_gateway" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.72.0/21"
  availability_zone = "us-east-1d"
}

resource "aws_subnet" "virginia_us_east_1d_compute" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.80.0/21"
  availability_zone = "us-east-1d"
}

resource "aws_subnet" "virginia_us_east_1d_storage" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.88.0/21"
  availability_zone = "us-east-1d"
}

resource "aws_subnet" "virginia_us_east_1e_gateway" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.96.0/21"
  availability_zone = "us-east-1e"
}

resource "aws_subnet" "virginia_us_east_1e_compute" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.104.0/21"
  availability_zone = "us-east-1e"
}

resource "aws_subnet" "virginia_us_east_1e_storage" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.112.0/21"
  availability_zone = "us-east-1e"
}

resource "aws_subnet" "virginia_us_east_1f_gateway" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.120.0/21"
  availability_zone = "us-east-1f"
}

resource "aws_subnet" "virginia_us_east_1f_compute" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.128.0/21"
  availability_zone = "us-east-1f"
}

resource "aws_subnet" "virginia_us_east_1f_storage" {
  vpc_id = aws_vpc.virginia.id
  cidr_block = "10.4.136.0/21"
  availability_zone = "us-east-1f"
}

output "lb_arn" {
  value = aws_lb.lb.arn
}