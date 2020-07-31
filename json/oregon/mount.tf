
provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "oregon" {
  cidr_block = "10.2.0.0/16"
}

resource "aws_lb" "lb" {
  name = "oregon"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
    aws_subnet.oregon_us_west_2a_gateway.id,
    aws_subnet.oregon_us_west_2b_gateway.id,
    aws_subnet.oregon_us_west_2c_gateway.id
  ]
  enable_http2 = true
}

resource "aws_security_group" "https" {
  name = "oregon"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = aws_vpc.oregon.id
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.2.0.0/21",
      "10.2.24.0/21",
      "10.2.48.0/21"
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

resource "aws_subnet" "oregon_us_west_2a_gateway" {
  vpc_id = aws_vpc.oregon.id
  cidr_block = "10.2.0.0/21"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "oregon_us_west_2a_compute" {
  vpc_id = aws_vpc.oregon.id
  cidr_block = "10.2.8.0/21"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "oregon_us_west_2a_storage" {
  vpc_id = aws_vpc.oregon.id
  cidr_block = "10.2.16.0/21"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "oregon_us_west_2b_gateway" {
  vpc_id = aws_vpc.oregon.id
  cidr_block = "10.2.24.0/21"
  availability_zone = "us-west-2b"
}

resource "aws_subnet" "oregon_us_west_2b_compute" {
  vpc_id = aws_vpc.oregon.id
  cidr_block = "10.2.32.0/21"
  availability_zone = "us-west-2b"
}

resource "aws_subnet" "oregon_us_west_2b_storage" {
  vpc_id = aws_vpc.oregon.id
  cidr_block = "10.2.40.0/21"
  availability_zone = "us-west-2b"
}

resource "aws_subnet" "oregon_us_west_2c_gateway" {
  vpc_id = aws_vpc.oregon.id
  cidr_block = "10.2.48.0/21"
  availability_zone = "us-west-2c"
}

resource "aws_subnet" "oregon_us_west_2c_compute" {
  vpc_id = aws_vpc.oregon.id
  cidr_block = "10.2.56.0/21"
  availability_zone = "us-west-2c"
}

resource "aws_subnet" "oregon_us_west_2c_storage" {
  vpc_id = aws_vpc.oregon.id
  cidr_block = "10.2.64.0/21"
  availability_zone = "us-west-2c"
}

output "lb_arn" {
  value = aws_lb.lb.arn
}