
provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.12.0.0/16"
  
  tags = {
    name = "vpc"
    env = "front"
    region = "ap-southeast-1"
    creator = "Lance"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_lb" "lb" {
  name = "singapore"
  internal = false
  load_balancer_type = "application"
  enable_http2 = true
  security_groups = [
    aws_security_group.gateway.id
  ]
  subnets = [
    aws_subnet.ap_southeast_1a_gateway.id,
    aws_subnet.ap_southeast_1b_gateway.id,
    aws_subnet.ap_southeast_1c_gateway.id
  ]
  
  tags = {
    name = "vpc"
    env = "front"
    region = "ap-southeast-1"
    creator = "Lance"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_lb_target_group" "singapore_gateway" {
  port = "80"
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "singapore_gateway"
    env = "front"
    region = "ap-southeast-1"
    creator = "Lance"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_acm_certificate" "singapore_gateway" {
  domain_name = "example.com"
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    name = "singapore_gateway"
    env = "front"
    region = "ap-southeast-1"
    creator = "Lance"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_lb_listener" "singapore_gateway" {
  load_balancer_arn = aws_lb.lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.singapore_gateway.arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.singapore_gateway.arn
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "ig"
    env = "front"
    region = "ap-southeast-1"
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
      "10.12.0.0/21",
      "10.12.32.0/21",
      "10.12.64.0/21"
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
      "10.12.0.0/21",
      "10.12.32.0/21",
      "10.12.64.0/21"
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
      "10.12.0.0/21",
      "10.12.32.0/21",
      "10.12.64.0/21"
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
      "10.12.0.0/21",
      "10.12.32.0/21",
      "10.12.64.0/21"
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
      "10.12.0.0/21",
      "10.12.32.0/21",
      "10.12.64.0/21"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.12.0.0/21",
      "10.12.32.0/21",
      "10.12.64.0/21"
    ]
  }
}

resource "aws_eip" "ap_southeast_1a_gateway" {
  vpc = true
  network_interface = aws_network_interface.ap_southeast_1a_gateway.id
  
  tags = {
    name = "ap_southeast_1a_gateway"
    env = "front"
    zone = "ap-southeast-1a"
    creator = "Lance"
    region = "ap-southeast-1"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_nat_gateway" "ap_southeast_1a_gateway" {
  subnet_id = aws_subnet.ap_southeast_1a_gateway.id
  allocation_id = aws_eip.ap_southeast_1a_gateway.id
  
  tags = {
    name = "ap_southeast_1a_gateway"
    region = "ap-southeast-1"
    zone = "ap-southeast-1a"
    creator = "Lance"
    env = "front"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_subnet" "ap_southeast_1a_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.8.0/21"
  availability_zone = "ap-southeast-1a"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1a"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1a_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1a_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1a"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1a_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1a_gateway" {
  subnet_id = aws_subnet.ap_southeast_1a_gateway.id
  route_table_id = aws_route_table.ap_southeast_1a_gateway.id
}

resource "aws_route" "ap_southeast_1a_gateway_compute" {
  route_table_id = aws_route_table.ap_southeast_1a_gateway.id
  destination_cidr_block = "10.12.0.0/21"
}

resource "aws_network_interface" "ap_southeast_1a_gateway" {
  subnet_id = aws_subnet.ap_southeast_1a_gateway.id
}

resource "aws_subnet" "ap_southeast_1a_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.0.0/21"
  availability_zone = "ap-southeast-1a"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1a"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1a_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1a_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1a"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1a_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1a_compute" {
  subnet_id = aws_subnet.ap_southeast_1a_gateway.id
  route_table_id = aws_route_table.ap_southeast_1a_compute.id
}

resource "aws_route" "ap_southeast_1a_compute_storage" {
  route_table_id = aws_route_table.ap_southeast_1a_compute.id
  destination_cidr_block = "10.12.16.0/21"
}

resource "aws_route" "ap_southeast_1a_compute_gateway" {
  route_table_id = aws_route_table.ap_southeast_1a_compute.id
  destination_cidr_block = "10.12.8.0/21"
}

resource "aws_route" "ap_southeast_1a_compute_connect" {
  route_table_id = aws_route_table.ap_southeast_1a_compute.id
  destination_cidr_block = "10.12.24.0/21"
}

resource "aws_network_interface" "ap_southeast_1a_compute" {
  subnet_id = aws_subnet.ap_southeast_1a_gateway.id
}

resource "aws_subnet" "ap_southeast_1a_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.16.0/21"
  availability_zone = "ap-southeast-1a"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1a"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1a_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1a_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1a"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1a_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1a_storage" {
  subnet_id = aws_subnet.ap_southeast_1a_gateway.id
  route_table_id = aws_route_table.ap_southeast_1a_storage.id
}

resource "aws_route" "ap_southeast_1a_storage_compute" {
  route_table_id = aws_route_table.ap_southeast_1a_storage.id
  destination_cidr_block = "10.12.0.0/21"
}

resource "aws_network_interface" "ap_southeast_1a_storage" {
  subnet_id = aws_subnet.ap_southeast_1a_gateway.id
}

resource "aws_subnet" "ap_southeast_1a_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.24.0/21"
  availability_zone = "ap-southeast-1a"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1a"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1a_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1a_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1a"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1a_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1a_connect" {
  subnet_id = aws_subnet.ap_southeast_1a_gateway.id
  route_table_id = aws_route_table.ap_southeast_1a_connect.id
}

resource "aws_route" "ap_southeast_1a_connect_compute" {
  route_table_id = aws_route_table.ap_southeast_1a_connect.id
  destination_cidr_block = "10.12.0.0/21"
}

resource "aws_route" "ap_southeast_1a_connect_outside" {
  route_table_id = aws_route_table.ap_southeast_1a_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ap_southeast_1a_connect" {
  subnet_id = aws_subnet.ap_southeast_1a_gateway.id
}

resource "aws_network_acl" "ap_southeast_1a_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ap_southeast_1a_gateway.id
  ]
  
  tags = {
    env = "front"
    zone = "ap-southeast-1a"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1a_gateway"
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

resource "aws_eip" "ap_southeast_1b_gateway" {
  vpc = true
  network_interface = aws_network_interface.ap_southeast_1b_gateway.id
  
  tags = {
    name = "ap_southeast_1b_gateway"
    env = "front"
    zone = "ap-southeast-1b"
    creator = "Lance"
    region = "ap-southeast-1"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_nat_gateway" "ap_southeast_1b_gateway" {
  subnet_id = aws_subnet.ap_southeast_1b_gateway.id
  allocation_id = aws_eip.ap_southeast_1b_gateway.id
  
  tags = {
    name = "ap_southeast_1b_gateway"
    region = "ap-southeast-1"
    zone = "ap-southeast-1b"
    creator = "Lance"
    env = "front"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_subnet" "ap_southeast_1b_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.32.0/21"
  availability_zone = "ap-southeast-1b"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1b"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1b_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1b_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1b"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1b_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1b_gateway" {
  subnet_id = aws_subnet.ap_southeast_1b_gateway.id
  route_table_id = aws_route_table.ap_southeast_1b_gateway.id
}

resource "aws_route" "ap_southeast_1b_gateway_compute" {
  route_table_id = aws_route_table.ap_southeast_1b_gateway.id
  destination_cidr_block = "10.12.24.0/21"
}

resource "aws_network_interface" "ap_southeast_1b_gateway" {
  subnet_id = aws_subnet.ap_southeast_1b_gateway.id
}

resource "aws_subnet" "ap_southeast_1b_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.24.0/21"
  availability_zone = "ap-southeast-1b"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1b"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1b_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1b_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1b"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1b_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1b_compute" {
  subnet_id = aws_subnet.ap_southeast_1b_gateway.id
  route_table_id = aws_route_table.ap_southeast_1b_compute.id
}

resource "aws_route" "ap_southeast_1b_compute_storage" {
  route_table_id = aws_route_table.ap_southeast_1b_compute.id
  destination_cidr_block = "10.12.40.0/21"
}

resource "aws_route" "ap_southeast_1b_compute_gateway" {
  route_table_id = aws_route_table.ap_southeast_1b_compute.id
  destination_cidr_block = "10.12.32.0/21"
}

resource "aws_route" "ap_southeast_1b_compute_connect" {
  route_table_id = aws_route_table.ap_southeast_1b_compute.id
  destination_cidr_block = "10.12.48.0/21"
}

resource "aws_network_interface" "ap_southeast_1b_compute" {
  subnet_id = aws_subnet.ap_southeast_1b_gateway.id
}

resource "aws_subnet" "ap_southeast_1b_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.40.0/21"
  availability_zone = "ap-southeast-1b"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1b"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1b_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1b_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1b"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1b_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1b_storage" {
  subnet_id = aws_subnet.ap_southeast_1b_gateway.id
  route_table_id = aws_route_table.ap_southeast_1b_storage.id
}

resource "aws_route" "ap_southeast_1b_storage_compute" {
  route_table_id = aws_route_table.ap_southeast_1b_storage.id
  destination_cidr_block = "10.12.24.0/21"
}

resource "aws_network_interface" "ap_southeast_1b_storage" {
  subnet_id = aws_subnet.ap_southeast_1b_gateway.id
}

resource "aws_subnet" "ap_southeast_1b_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.48.0/21"
  availability_zone = "ap-southeast-1b"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1b"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1b_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1b_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1b"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1b_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1b_connect" {
  subnet_id = aws_subnet.ap_southeast_1b_gateway.id
  route_table_id = aws_route_table.ap_southeast_1b_connect.id
}

resource "aws_route" "ap_southeast_1b_connect_compute" {
  route_table_id = aws_route_table.ap_southeast_1b_connect.id
  destination_cidr_block = "10.12.24.0/21"
}

resource "aws_route" "ap_southeast_1b_connect_outside" {
  route_table_id = aws_route_table.ap_southeast_1b_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ap_southeast_1b_connect" {
  subnet_id = aws_subnet.ap_southeast_1b_gateway.id
}

resource "aws_network_acl" "ap_southeast_1b_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ap_southeast_1b_gateway.id
  ]
  
  tags = {
    env = "front"
    zone = "ap-southeast-1b"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1b_gateway"
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

resource "aws_eip" "ap_southeast_1c_gateway" {
  vpc = true
  network_interface = aws_network_interface.ap_southeast_1c_gateway.id
  
  tags = {
    name = "ap_southeast_1c_gateway"
    env = "front"
    zone = "ap-southeast-1c"
    creator = "Lance"
    region = "ap-southeast-1"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_nat_gateway" "ap_southeast_1c_gateway" {
  subnet_id = aws_subnet.ap_southeast_1c_gateway.id
  allocation_id = aws_eip.ap_southeast_1c_gateway.id
  
  tags = {
    name = "ap_southeast_1c_gateway"
    region = "ap-southeast-1"
    zone = "ap-southeast-1c"
    creator = "Lance"
    env = "front"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_subnet" "ap_southeast_1c_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.56.0/21"
  availability_zone = "ap-southeast-1c"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1c"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1c_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1c_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1c"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1c_gateway"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1c_gateway" {
  subnet_id = aws_subnet.ap_southeast_1c_gateway.id
  route_table_id = aws_route_table.ap_southeast_1c_gateway.id
}

resource "aws_route" "ap_southeast_1c_gateway_compute" {
  route_table_id = aws_route_table.ap_southeast_1c_gateway.id
  destination_cidr_block = "10.12.48.0/21"
}

resource "aws_network_interface" "ap_southeast_1c_gateway" {
  subnet_id = aws_subnet.ap_southeast_1c_gateway.id
}

resource "aws_subnet" "ap_southeast_1c_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.48.0/21"
  availability_zone = "ap-southeast-1c"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1c"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1c_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1c_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1c"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1c_compute"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1c_compute" {
  subnet_id = aws_subnet.ap_southeast_1c_gateway.id
  route_table_id = aws_route_table.ap_southeast_1c_compute.id
}

resource "aws_route" "ap_southeast_1c_compute_storage" {
  route_table_id = aws_route_table.ap_southeast_1c_compute.id
  destination_cidr_block = "10.12.64.0/21"
}

resource "aws_route" "ap_southeast_1c_compute_gateway" {
  route_table_id = aws_route_table.ap_southeast_1c_compute.id
  destination_cidr_block = "10.12.56.0/21"
}

resource "aws_route" "ap_southeast_1c_compute_connect" {
  route_table_id = aws_route_table.ap_southeast_1c_compute.id
  destination_cidr_block = "10.12.72.0/21"
}

resource "aws_network_interface" "ap_southeast_1c_compute" {
  subnet_id = aws_subnet.ap_southeast_1c_gateway.id
}

resource "aws_subnet" "ap_southeast_1c_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.64.0/21"
  availability_zone = "ap-southeast-1c"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1c"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1c_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1c_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1c"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1c_storage"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1c_storage" {
  subnet_id = aws_subnet.ap_southeast_1c_gateway.id
  route_table_id = aws_route_table.ap_southeast_1c_storage.id
}

resource "aws_route" "ap_southeast_1c_storage_compute" {
  route_table_id = aws_route_table.ap_southeast_1c_storage.id
  destination_cidr_block = "10.12.48.0/21"
}

resource "aws_network_interface" "ap_southeast_1c_storage" {
  subnet_id = aws_subnet.ap_southeast_1c_gateway.id
}

resource "aws_subnet" "ap_southeast_1c_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.12.72.0/21"
  availability_zone = "ap-southeast-1c"
  
  tags = {
    env = "front"
    zone = "ap-southeast-1c"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1c_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table" "ap_southeast_1c_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-1c"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1c_connect"
    build_version = "0.0.1"
    planned = "2020-07-31T21:43:29-07:00"
  }
}

resource "aws_route_table_association" "ap_southeast_1c_connect" {
  subnet_id = aws_subnet.ap_southeast_1c_gateway.id
  route_table_id = aws_route_table.ap_southeast_1c_connect.id
}

resource "aws_route" "ap_southeast_1c_connect_compute" {
  route_table_id = aws_route_table.ap_southeast_1c_connect.id
  destination_cidr_block = "10.12.48.0/21"
}

resource "aws_route" "ap_southeast_1c_connect_outside" {
  route_table_id = aws_route_table.ap_southeast_1c_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ap_southeast_1c_connect" {
  subnet_id = aws_subnet.ap_southeast_1c_gateway.id
}

resource "aws_network_acl" "ap_southeast_1c_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ap_southeast_1c_gateway.id
  ]
  
  tags = {
    env = "front"
    zone = "ap-southeast-1c"
    creator = "Lance"
    region = "ap-southeast-1"
    name = "ap_southeast_1c_gateway"
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