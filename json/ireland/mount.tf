
provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "ireland" {
  cidr_block = "10.6.0.0/16"
}

resource "aws_lb" "lb" {
  name = "ireland"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
    aws_subnet.ireland_eu_west_1a_gateway.id,
    aws_subnet.ireland_eu_west_1b_gateway.id,
    aws_subnet.ireland_eu_west_1c_gateway.id
  ]
  enable_http2 = true
}

resource "aws_security_group" "https" {
  name = "ireland"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = aws_vpc.ireland.id
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.6.0.0/21",
      "10.6.24.0/21",
      "10.6.48.0/21"
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

resource "aws_subnet" "ireland_eu_west_1a_gateway" {
  vpc_id = aws_vpc.ireland.id
  cidr_block = "10.6.0.0/21"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "ireland_eu_west_1a_compute" {
  vpc_id = aws_vpc.ireland.id
  cidr_block = "10.6.8.0/21"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "ireland_eu_west_1a_storage" {
  vpc_id = aws_vpc.ireland.id
  cidr_block = "10.6.16.0/21"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "ireland_eu_west_1b_gateway" {
  vpc_id = aws_vpc.ireland.id
  cidr_block = "10.6.24.0/21"
  availability_zone = "eu-west-1b"
}

resource "aws_subnet" "ireland_eu_west_1b_compute" {
  vpc_id = aws_vpc.ireland.id
  cidr_block = "10.6.32.0/21"
  availability_zone = "eu-west-1b"
}

resource "aws_subnet" "ireland_eu_west_1b_storage" {
  vpc_id = aws_vpc.ireland.id
  cidr_block = "10.6.40.0/21"
  availability_zone = "eu-west-1b"
}

resource "aws_subnet" "ireland_eu_west_1c_gateway" {
  vpc_id = aws_vpc.ireland.id
  cidr_block = "10.6.48.0/21"
  availability_zone = "eu-west-1c"
}

resource "aws_subnet" "ireland_eu_west_1c_compute" {
  vpc_id = aws_vpc.ireland.id
  cidr_block = "10.6.56.0/21"
  availability_zone = "eu-west-1c"
}

resource "aws_subnet" "ireland_eu_west_1c_storage" {
  vpc_id = aws_vpc.ireland.id
  cidr_block = "10.6.64.0/21"
  availability_zone = "eu-west-1c"
}

output "lb_arn" {
  value = aws_lb.lb.arn
}