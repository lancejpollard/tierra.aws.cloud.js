
provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "london" {
  cidr_block = "10.7.0.0/16"
}

resource "aws_lb" "lb" {
  name = "london"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
    aws_subnet.london_eu_west_2a_gateway.id,
    aws_subnet.london_eu_west_2b_gateway.id,
    aws_subnet.london_eu_west_2c_gateway.id
  ]
  enable_http2 = true
}

resource "aws_security_group" "https" {
  name = "london"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = aws_vpc.london.id
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.7.0.0/21",
      "10.7.24.0/21",
      "10.7.48.0/21"
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

resource "aws_subnet" "london_eu_west_2a_gateway" {
  vpc_id = aws_vpc.london.id
  cidr_block = "10.7.0.0/21"
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "london_eu_west_2a_compute" {
  vpc_id = aws_vpc.london.id
  cidr_block = "10.7.8.0/21"
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "london_eu_west_2a_storage" {
  vpc_id = aws_vpc.london.id
  cidr_block = "10.7.16.0/21"
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "london_eu_west_2b_gateway" {
  vpc_id = aws_vpc.london.id
  cidr_block = "10.7.24.0/21"
  availability_zone = "eu-west-2b"
}

resource "aws_subnet" "london_eu_west_2b_compute" {
  vpc_id = aws_vpc.london.id
  cidr_block = "10.7.32.0/21"
  availability_zone = "eu-west-2b"
}

resource "aws_subnet" "london_eu_west_2b_storage" {
  vpc_id = aws_vpc.london.id
  cidr_block = "10.7.40.0/21"
  availability_zone = "eu-west-2b"
}

resource "aws_subnet" "london_eu_west_2c_gateway" {
  vpc_id = aws_vpc.london.id
  cidr_block = "10.7.48.0/21"
  availability_zone = "eu-west-2c"
}

resource "aws_subnet" "london_eu_west_2c_compute" {
  vpc_id = aws_vpc.london.id
  cidr_block = "10.7.56.0/21"
  availability_zone = "eu-west-2c"
}

resource "aws_subnet" "london_eu_west_2c_storage" {
  vpc_id = aws_vpc.london.id
  cidr_block = "10.7.64.0/21"
  availability_zone = "eu-west-2c"
}

output "lb_arn" {
  value = aws_lb.lb.arn
}