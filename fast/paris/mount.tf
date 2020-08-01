
provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.8.0.0/16"
  
  tags = {
    name = "vpc"
    env = "front"
    region = "eu-west-3"
    creator = "Lance"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_lb" "lb" {
  name = "paris"
  internal = false
  load_balancer_type = "application"
  enable_http2 = true
  security_groups = [
    aws_security_group.gateway.id
  ]
  subnets = [
    aws_subnet.eu_west_3a_gateway.id,
    aws_subnet.eu_west_3b_gateway.id,
    aws_subnet.eu_west_3c_gateway.id
  ]
  
  tags = {
    name = "vpc"
    env = "front"
    region = "eu-west-3"
    creator = "Lance"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_lb_target_group" "paris_gateway" {
  port = "80"
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "paris_gateway"
    env = "front"
    region = "eu-west-3"
    creator = "Lance"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_acm_certificate" "paris_gateway" {
  domain_name = "example.com"
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    name = "paris_gateway"
    env = "front"
    region = "eu-west-3"
    creator = "Lance"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_lb_listener" "paris_gateway" {
  load_balancer_arn = aws_lb.lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.paris_gateway.arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.paris_gateway.arn
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "ig"
    env = "front"
    region = "eu-west-3"
    creator = "Lance"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_security_group" "gateway" {
  description = "Allow communication of gateway with internet and compute"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  ingress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.8.0.0/21",
      "10.8.32.0/21",
      "10.8.64.0/21"
    ]
  }
  
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.8.0.0/21",
      "10.8.32.0/21",
      "10.8.64.0/21"
    ]
  }
}

resource "aws_security_group" "compute" {
  description = "Allow compute to communicate with internal nodes only"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
  }
}

resource "aws_security_group" "connect" {
  description = "Allow communication of connect nodes"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.8.0.0/21",
      "10.8.32.0/21",
      "10.8.64.0/21"
    ]
  }
  
  egress {
    from_port = 10000
    to_port = 10000
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.8.0.0/21",
      "10.8.32.0/21",
      "10.8.64.0/21"
    ]
  }
}

resource "aws_security_group" "storage" {
  description = "Allow storage to communicate with compute nodes only"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.8.0.0/21",
      "10.8.32.0/21",
      "10.8.64.0/21"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.8.0.0/21",
      "10.8.32.0/21",
      "10.8.64.0/21"
    ]
  }
}

resource "aws_eip" "eu_west_3a_gateway" {
  vpc = true
  network_interface = aws_network_interface.eu_west_3a_gateway.id
  
  tags = {
    name = "eu_west_3a_gateway"
    env = "front"
    zone = "eu-west-3a"
    creator = "Lance"
    region = "eu-west-3"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_nat_gateway" "eu_west_3a_gateway" {
  subnet_id = aws_subnet.eu_west_3a_gateway.id
  allocation_id = aws_eip.eu_west_3a_gateway.id
  
  tags = {
    name = "eu_west_3a_gateway"
    region = "eu-west-3"
    zone = "eu-west-3a"
    creator = "Lance"
    env = "front"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_subnet" "eu_west_3a_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.8.0/21"
  availability_zone = "eu-west-3a"
  
  tags = {
    env = "front"
    zone = "eu-west-3a"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3a_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3a_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3a"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3a_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3a_gateway" {
  subnet_id = aws_subnet.eu_west_3a_gateway.id
  route_table_id = aws_route_table.eu_west_3a_gateway.id
}

resource "aws_route" "eu_west_3a_gateway_compute" {
  route_table_id = aws_route_table.eu_west_3a_gateway.id
  destination_cidr_block = "10.8.0.0/21"
}

resource "aws_network_interface" "eu_west_3a_gateway" {
  subnet_id = aws_subnet.eu_west_3a_gateway.id
}

resource "aws_subnet" "eu_west_3a_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.0.0/21"
  availability_zone = "eu-west-3a"
  
  tags = {
    env = "front"
    zone = "eu-west-3a"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3a_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3a_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3a"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3a_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3a_compute" {
  subnet_id = aws_subnet.eu_west_3a_gateway.id
  route_table_id = aws_route_table.eu_west_3a_compute.id
}

resource "aws_route" "eu_west_3a_compute_storage" {
  route_table_id = aws_route_table.eu_west_3a_compute.id
  destination_cidr_block = "10.8.16.0/21"
}

resource "aws_route" "eu_west_3a_compute_gateway" {
  route_table_id = aws_route_table.eu_west_3a_compute.id
  destination_cidr_block = "10.8.8.0/21"
}

resource "aws_route" "eu_west_3a_compute_connect" {
  route_table_id = aws_route_table.eu_west_3a_compute.id
  destination_cidr_block = "10.8.24.0/21"
}

resource "aws_network_interface" "eu_west_3a_compute" {
  subnet_id = aws_subnet.eu_west_3a_gateway.id
}

resource "aws_subnet" "eu_west_3a_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.16.0/21"
  availability_zone = "eu-west-3a"
  
  tags = {
    env = "front"
    zone = "eu-west-3a"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3a_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3a_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3a"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3a_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3a_storage" {
  subnet_id = aws_subnet.eu_west_3a_gateway.id
  route_table_id = aws_route_table.eu_west_3a_storage.id
}

resource "aws_route" "eu_west_3a_storage_compute" {
  route_table_id = aws_route_table.eu_west_3a_storage.id
  destination_cidr_block = "10.8.0.0/21"
}

resource "aws_network_interface" "eu_west_3a_storage" {
  subnet_id = aws_subnet.eu_west_3a_gateway.id
}

resource "aws_subnet" "eu_west_3a_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.24.0/21"
  availability_zone = "eu-west-3a"
  
  tags = {
    env = "front"
    zone = "eu-west-3a"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3a_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3a_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3a"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3a_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3a_connect" {
  subnet_id = aws_subnet.eu_west_3a_gateway.id
  route_table_id = aws_route_table.eu_west_3a_connect.id
}

resource "aws_route" "eu_west_3a_connect_compute" {
  route_table_id = aws_route_table.eu_west_3a_connect.id
  destination_cidr_block = "10.8.0.0/21"
}

resource "aws_route" "eu_west_3a_connect_outside" {
  route_table_id = aws_route_table.eu_west_3a_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "eu_west_3a_connect" {
  subnet_id = aws_subnet.eu_west_3a_gateway.id
}

resource "aws_network_acl" "eu_west_3a_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.eu_west_3a_gateway.id
  ]
  
  tags = {
    env = "front"
    zone = "eu-west-3a"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3a_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
}

resource "aws_eip" "eu_west_3b_gateway" {
  vpc = true
  network_interface = aws_network_interface.eu_west_3b_gateway.id
  
  tags = {
    name = "eu_west_3b_gateway"
    env = "front"
    zone = "eu-west-3b"
    creator = "Lance"
    region = "eu-west-3"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_nat_gateway" "eu_west_3b_gateway" {
  subnet_id = aws_subnet.eu_west_3b_gateway.id
  allocation_id = aws_eip.eu_west_3b_gateway.id
  
  tags = {
    name = "eu_west_3b_gateway"
    region = "eu-west-3"
    zone = "eu-west-3b"
    creator = "Lance"
    env = "front"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_subnet" "eu_west_3b_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.32.0/21"
  availability_zone = "eu-west-3b"
  
  tags = {
    env = "front"
    zone = "eu-west-3b"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3b_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3b_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3b"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3b_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3b_gateway" {
  subnet_id = aws_subnet.eu_west_3b_gateway.id
  route_table_id = aws_route_table.eu_west_3b_gateway.id
}

resource "aws_route" "eu_west_3b_gateway_compute" {
  route_table_id = aws_route_table.eu_west_3b_gateway.id
  destination_cidr_block = "10.8.24.0/21"
}

resource "aws_network_interface" "eu_west_3b_gateway" {
  subnet_id = aws_subnet.eu_west_3b_gateway.id
}

resource "aws_subnet" "eu_west_3b_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.24.0/21"
  availability_zone = "eu-west-3b"
  
  tags = {
    env = "front"
    zone = "eu-west-3b"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3b_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3b_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3b"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3b_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3b_compute" {
  subnet_id = aws_subnet.eu_west_3b_gateway.id
  route_table_id = aws_route_table.eu_west_3b_compute.id
}

resource "aws_route" "eu_west_3b_compute_storage" {
  route_table_id = aws_route_table.eu_west_3b_compute.id
  destination_cidr_block = "10.8.40.0/21"
}

resource "aws_route" "eu_west_3b_compute_gateway" {
  route_table_id = aws_route_table.eu_west_3b_compute.id
  destination_cidr_block = "10.8.32.0/21"
}

resource "aws_route" "eu_west_3b_compute_connect" {
  route_table_id = aws_route_table.eu_west_3b_compute.id
  destination_cidr_block = "10.8.48.0/21"
}

resource "aws_network_interface" "eu_west_3b_compute" {
  subnet_id = aws_subnet.eu_west_3b_gateway.id
}

resource "aws_subnet" "eu_west_3b_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.40.0/21"
  availability_zone = "eu-west-3b"
  
  tags = {
    env = "front"
    zone = "eu-west-3b"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3b_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3b_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3b"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3b_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3b_storage" {
  subnet_id = aws_subnet.eu_west_3b_gateway.id
  route_table_id = aws_route_table.eu_west_3b_storage.id
}

resource "aws_route" "eu_west_3b_storage_compute" {
  route_table_id = aws_route_table.eu_west_3b_storage.id
  destination_cidr_block = "10.8.24.0/21"
}

resource "aws_network_interface" "eu_west_3b_storage" {
  subnet_id = aws_subnet.eu_west_3b_gateway.id
}

resource "aws_subnet" "eu_west_3b_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.48.0/21"
  availability_zone = "eu-west-3b"
  
  tags = {
    env = "front"
    zone = "eu-west-3b"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3b_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3b_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3b"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3b_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3b_connect" {
  subnet_id = aws_subnet.eu_west_3b_gateway.id
  route_table_id = aws_route_table.eu_west_3b_connect.id
}

resource "aws_route" "eu_west_3b_connect_compute" {
  route_table_id = aws_route_table.eu_west_3b_connect.id
  destination_cidr_block = "10.8.24.0/21"
}

resource "aws_route" "eu_west_3b_connect_outside" {
  route_table_id = aws_route_table.eu_west_3b_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "eu_west_3b_connect" {
  subnet_id = aws_subnet.eu_west_3b_gateway.id
}

resource "aws_network_acl" "eu_west_3b_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.eu_west_3b_gateway.id
  ]
  
  tags = {
    env = "front"
    zone = "eu-west-3b"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3b_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
}

resource "aws_eip" "eu_west_3c_gateway" {
  vpc = true
  network_interface = aws_network_interface.eu_west_3c_gateway.id
  
  tags = {
    name = "eu_west_3c_gateway"
    env = "front"
    zone = "eu-west-3c"
    creator = "Lance"
    region = "eu-west-3"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_nat_gateway" "eu_west_3c_gateway" {
  subnet_id = aws_subnet.eu_west_3c_gateway.id
  allocation_id = aws_eip.eu_west_3c_gateway.id
  
  tags = {
    name = "eu_west_3c_gateway"
    region = "eu-west-3"
    zone = "eu-west-3c"
    creator = "Lance"
    env = "front"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_subnet" "eu_west_3c_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.56.0/21"
  availability_zone = "eu-west-3c"
  
  tags = {
    env = "front"
    zone = "eu-west-3c"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3c_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3c_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3c"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3c_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3c_gateway" {
  subnet_id = aws_subnet.eu_west_3c_gateway.id
  route_table_id = aws_route_table.eu_west_3c_gateway.id
}

resource "aws_route" "eu_west_3c_gateway_compute" {
  route_table_id = aws_route_table.eu_west_3c_gateway.id
  destination_cidr_block = "10.8.48.0/21"
}

resource "aws_network_interface" "eu_west_3c_gateway" {
  subnet_id = aws_subnet.eu_west_3c_gateway.id
}

resource "aws_subnet" "eu_west_3c_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.48.0/21"
  availability_zone = "eu-west-3c"
  
  tags = {
    env = "front"
    zone = "eu-west-3c"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3c_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3c_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3c"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3c_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3c_compute" {
  subnet_id = aws_subnet.eu_west_3c_gateway.id
  route_table_id = aws_route_table.eu_west_3c_compute.id
}

resource "aws_route" "eu_west_3c_compute_storage" {
  route_table_id = aws_route_table.eu_west_3c_compute.id
  destination_cidr_block = "10.8.64.0/21"
}

resource "aws_route" "eu_west_3c_compute_gateway" {
  route_table_id = aws_route_table.eu_west_3c_compute.id
  destination_cidr_block = "10.8.56.0/21"
}

resource "aws_route" "eu_west_3c_compute_connect" {
  route_table_id = aws_route_table.eu_west_3c_compute.id
  destination_cidr_block = "10.8.72.0/21"
}

resource "aws_network_interface" "eu_west_3c_compute" {
  subnet_id = aws_subnet.eu_west_3c_gateway.id
}

resource "aws_subnet" "eu_west_3c_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.64.0/21"
  availability_zone = "eu-west-3c"
  
  tags = {
    env = "front"
    zone = "eu-west-3c"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3c_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3c_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3c"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3c_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3c_storage" {
  subnet_id = aws_subnet.eu_west_3c_gateway.id
  route_table_id = aws_route_table.eu_west_3c_storage.id
}

resource "aws_route" "eu_west_3c_storage_compute" {
  route_table_id = aws_route_table.eu_west_3c_storage.id
  destination_cidr_block = "10.8.48.0/21"
}

resource "aws_network_interface" "eu_west_3c_storage" {
  subnet_id = aws_subnet.eu_west_3c_gateway.id
}

resource "aws_subnet" "eu_west_3c_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.8.72.0/21"
  availability_zone = "eu-west-3c"
  
  tags = {
    env = "front"
    zone = "eu-west-3c"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3c_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "eu_west_3c_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "eu-west-3c"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3c_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "eu_west_3c_connect" {
  subnet_id = aws_subnet.eu_west_3c_gateway.id
  route_table_id = aws_route_table.eu_west_3c_connect.id
}

resource "aws_route" "eu_west_3c_connect_compute" {
  route_table_id = aws_route_table.eu_west_3c_connect.id
  destination_cidr_block = "10.8.48.0/21"
}

resource "aws_route" "eu_west_3c_connect_outside" {
  route_table_id = aws_route_table.eu_west_3c_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "eu_west_3c_connect" {
  subnet_id = aws_subnet.eu_west_3c_gateway.id
}

resource "aws_network_acl" "eu_west_3c_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.eu_west_3c_gateway.id
  ]
  
  tags = {
    env = "front"
    zone = "eu-west-3c"
    creator = "Lance"
    region = "eu-west-3"
    name = "eu_west_3c_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
}

output "lb_arn" {
  value = aws_lb.lb.arn
}
