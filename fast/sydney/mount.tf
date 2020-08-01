
provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.13.0.0/16"
  
  tags = {
    name = "vpc"
    env = "front"
    region = "ap-southeast-2"
    author = "Lance Pollard"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_lb" "lb" {
  name = "sydney"
  internal = false
  load_balancer_type = "application"
  enable_http2 = true
  security_groups = [
    aws_security_group.gateway.id
  ]
  subnets = [
    aws_subnet.ap_southeast_2a_gateway.id,
    aws_subnet.ap_southeast_2b_gateway.id,
    aws_subnet.ap_southeast_2c_gateway.id
  ]
  
  tags = {
    name = "vpc"
    env = "front"
    region = "ap-southeast-2"
    author = "Lance Pollard"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_lb_target_group" "sydney_gateway" {
  port = "80"
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "sydney_gateway"
    env = "front"
    region = "ap-southeast-2"
    author = "Lance Pollard"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_acm_certificate" "sydney_gateway" {
  domain_name = "example.com"
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    name = "sydney_gateway"
    env = "front"
    region = "ap-southeast-2"
    author = "Lance Pollard"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_lb_listener" "sydney_gateway" {
  load_balancer_arn = aws_lb.lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.sydney_gateway.arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.sydney_gateway.arn
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "ig"
    env = "front"
    region = "ap-southeast-2"
    author = "Lance Pollard"
    build_version = "1.0.0"
    planned = undefined
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
      "10.13.0.0/21",
      "10.13.32.0/21",
      "10.13.64.0/21"
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
      "10.13.0.0/21",
      "10.13.32.0/21",
      "10.13.64.0/21"
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
      "10.13.0.0/21",
      "10.13.32.0/21",
      "10.13.64.0/21"
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
      "10.13.0.0/21",
      "10.13.32.0/21",
      "10.13.64.0/21"
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
      "10.13.0.0/21",
      "10.13.32.0/21",
      "10.13.64.0/21"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.13.0.0/21",
      "10.13.32.0/21",
      "10.13.64.0/21"
    ]
  }
}

resource "aws_eip" "ap_southeast_2a_gateway" {
  vpc = true
  network_interface = aws_network_interface.ap_southeast_2a_gateway.id
  
  tags = {
    name = "ap_southeast_2a_gateway"
    env = "front"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_nat_gateway" "ap_southeast_2a_gateway" {
  subnet_id = aws_subnet.ap_southeast_2a_gateway.id
  allocation_id = aws_eip.ap_southeast_2a_gateway.id
  
  tags = {
    name = "ap_southeast_2a_gateway"
    region = "ap-southeast-2"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    env = "front"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_subnet" "ap_southeast_2a_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.8.0/21"
  availability_zone = "ap-southeast-2a"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2a_gateway"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2a_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2a_gateway"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2a_gateway" {
  subnet_id = aws_subnet.ap_southeast_2a_gateway.id
  route_table_id = aws_route_table.ap_southeast_2a_gateway.id
}

resource "aws_route" "ap_southeast_2a_gateway_compute" {
  route_table_id = aws_route_table.ap_southeast_2a_gateway.id
  destination_cidr_block = "10.13.0.0/21"
}

resource "aws_network_interface" "ap_southeast_2a_gateway" {
  subnet_id = aws_subnet.ap_southeast_2a_gateway.id
}

resource "aws_subnet" "ap_southeast_2a_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.0.0/21"
  availability_zone = "ap-southeast-2a"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2a_compute"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2a_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2a_compute"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2a_compute" {
  subnet_id = aws_subnet.ap_southeast_2a_gateway.id
  route_table_id = aws_route_table.ap_southeast_2a_compute.id
}

resource "aws_route" "ap_southeast_2a_compute_storage" {
  route_table_id = aws_route_table.ap_southeast_2a_compute.id
  destination_cidr_block = "10.13.16.0/21"
}

resource "aws_route" "ap_southeast_2a_compute_gateway" {
  route_table_id = aws_route_table.ap_southeast_2a_compute.id
  destination_cidr_block = "10.13.8.0/21"
}

resource "aws_route" "ap_southeast_2a_compute_connect" {
  route_table_id = aws_route_table.ap_southeast_2a_compute.id
  destination_cidr_block = "10.13.24.0/21"
}

resource "aws_network_interface" "ap_southeast_2a_compute" {
  subnet_id = aws_subnet.ap_southeast_2a_gateway.id
}

resource "aws_subnet" "ap_southeast_2a_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.16.0/21"
  availability_zone = "ap-southeast-2a"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2a_storage"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2a_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2a_storage"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2a_storage" {
  subnet_id = aws_subnet.ap_southeast_2a_gateway.id
  route_table_id = aws_route_table.ap_southeast_2a_storage.id
}

resource "aws_route" "ap_southeast_2a_storage_compute" {
  route_table_id = aws_route_table.ap_southeast_2a_storage.id
  destination_cidr_block = "10.13.0.0/21"
}

resource "aws_network_interface" "ap_southeast_2a_storage" {
  subnet_id = aws_subnet.ap_southeast_2a_gateway.id
}

resource "aws_subnet" "ap_southeast_2a_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.24.0/21"
  availability_zone = "ap-southeast-2a"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2a_connect"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2a_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2a_connect"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2a_connect" {
  subnet_id = aws_subnet.ap_southeast_2a_gateway.id
  route_table_id = aws_route_table.ap_southeast_2a_connect.id
}

resource "aws_route" "ap_southeast_2a_connect_compute" {
  route_table_id = aws_route_table.ap_southeast_2a_connect.id
  destination_cidr_block = "10.13.0.0/21"
}

resource "aws_route" "ap_southeast_2a_connect_outside" {
  route_table_id = aws_route_table.ap_southeast_2a_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ap_southeast_2a_connect" {
  subnet_id = aws_subnet.ap_southeast_2a_gateway.id
}

resource "aws_network_acl" "ap_southeast_2a_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ap_southeast_2a_gateway.id
  ]
  
  tags = {
    env = "front"
    zone = "ap-southeast-2a"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2a_gateway"
    build_version = "1.0.0"
    planned = undefined
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

resource "aws_eip" "ap_southeast_2b_gateway" {
  vpc = true
  network_interface = aws_network_interface.ap_southeast_2b_gateway.id
  
  tags = {
    name = "ap_southeast_2b_gateway"
    env = "front"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_nat_gateway" "ap_southeast_2b_gateway" {
  subnet_id = aws_subnet.ap_southeast_2b_gateway.id
  allocation_id = aws_eip.ap_southeast_2b_gateway.id
  
  tags = {
    name = "ap_southeast_2b_gateway"
    region = "ap-southeast-2"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    env = "front"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_subnet" "ap_southeast_2b_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.32.0/21"
  availability_zone = "ap-southeast-2b"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2b_gateway"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2b_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2b_gateway"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2b_gateway" {
  subnet_id = aws_subnet.ap_southeast_2b_gateway.id
  route_table_id = aws_route_table.ap_southeast_2b_gateway.id
}

resource "aws_route" "ap_southeast_2b_gateway_compute" {
  route_table_id = aws_route_table.ap_southeast_2b_gateway.id
  destination_cidr_block = "10.13.24.0/21"
}

resource "aws_network_interface" "ap_southeast_2b_gateway" {
  subnet_id = aws_subnet.ap_southeast_2b_gateway.id
}

resource "aws_subnet" "ap_southeast_2b_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.24.0/21"
  availability_zone = "ap-southeast-2b"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2b_compute"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2b_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2b_compute"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2b_compute" {
  subnet_id = aws_subnet.ap_southeast_2b_gateway.id
  route_table_id = aws_route_table.ap_southeast_2b_compute.id
}

resource "aws_route" "ap_southeast_2b_compute_storage" {
  route_table_id = aws_route_table.ap_southeast_2b_compute.id
  destination_cidr_block = "10.13.40.0/21"
}

resource "aws_route" "ap_southeast_2b_compute_gateway" {
  route_table_id = aws_route_table.ap_southeast_2b_compute.id
  destination_cidr_block = "10.13.32.0/21"
}

resource "aws_route" "ap_southeast_2b_compute_connect" {
  route_table_id = aws_route_table.ap_southeast_2b_compute.id
  destination_cidr_block = "10.13.48.0/21"
}

resource "aws_network_interface" "ap_southeast_2b_compute" {
  subnet_id = aws_subnet.ap_southeast_2b_gateway.id
}

resource "aws_subnet" "ap_southeast_2b_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.40.0/21"
  availability_zone = "ap-southeast-2b"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2b_storage"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2b_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2b_storage"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2b_storage" {
  subnet_id = aws_subnet.ap_southeast_2b_gateway.id
  route_table_id = aws_route_table.ap_southeast_2b_storage.id
}

resource "aws_route" "ap_southeast_2b_storage_compute" {
  route_table_id = aws_route_table.ap_southeast_2b_storage.id
  destination_cidr_block = "10.13.24.0/21"
}

resource "aws_network_interface" "ap_southeast_2b_storage" {
  subnet_id = aws_subnet.ap_southeast_2b_gateway.id
}

resource "aws_subnet" "ap_southeast_2b_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.48.0/21"
  availability_zone = "ap-southeast-2b"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2b_connect"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2b_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2b_connect"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2b_connect" {
  subnet_id = aws_subnet.ap_southeast_2b_gateway.id
  route_table_id = aws_route_table.ap_southeast_2b_connect.id
}

resource "aws_route" "ap_southeast_2b_connect_compute" {
  route_table_id = aws_route_table.ap_southeast_2b_connect.id
  destination_cidr_block = "10.13.24.0/21"
}

resource "aws_route" "ap_southeast_2b_connect_outside" {
  route_table_id = aws_route_table.ap_southeast_2b_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ap_southeast_2b_connect" {
  subnet_id = aws_subnet.ap_southeast_2b_gateway.id
}

resource "aws_network_acl" "ap_southeast_2b_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ap_southeast_2b_gateway.id
  ]
  
  tags = {
    env = "front"
    zone = "ap-southeast-2b"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2b_gateway"
    build_version = "1.0.0"
    planned = undefined
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

resource "aws_eip" "ap_southeast_2c_gateway" {
  vpc = true
  network_interface = aws_network_interface.ap_southeast_2c_gateway.id
  
  tags = {
    name = "ap_southeast_2c_gateway"
    env = "front"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_nat_gateway" "ap_southeast_2c_gateway" {
  subnet_id = aws_subnet.ap_southeast_2c_gateway.id
  allocation_id = aws_eip.ap_southeast_2c_gateway.id
  
  tags = {
    name = "ap_southeast_2c_gateway"
    region = "ap-southeast-2"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    env = "front"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_subnet" "ap_southeast_2c_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.56.0/21"
  availability_zone = "ap-southeast-2c"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2c_gateway"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2c_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2c_gateway"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2c_gateway" {
  subnet_id = aws_subnet.ap_southeast_2c_gateway.id
  route_table_id = aws_route_table.ap_southeast_2c_gateway.id
}

resource "aws_route" "ap_southeast_2c_gateway_compute" {
  route_table_id = aws_route_table.ap_southeast_2c_gateway.id
  destination_cidr_block = "10.13.48.0/21"
}

resource "aws_network_interface" "ap_southeast_2c_gateway" {
  subnet_id = aws_subnet.ap_southeast_2c_gateway.id
}

resource "aws_subnet" "ap_southeast_2c_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.48.0/21"
  availability_zone = "ap-southeast-2c"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2c_compute"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2c_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2c_compute"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2c_compute" {
  subnet_id = aws_subnet.ap_southeast_2c_gateway.id
  route_table_id = aws_route_table.ap_southeast_2c_compute.id
}

resource "aws_route" "ap_southeast_2c_compute_storage" {
  route_table_id = aws_route_table.ap_southeast_2c_compute.id
  destination_cidr_block = "10.13.64.0/21"
}

resource "aws_route" "ap_southeast_2c_compute_gateway" {
  route_table_id = aws_route_table.ap_southeast_2c_compute.id
  destination_cidr_block = "10.13.56.0/21"
}

resource "aws_route" "ap_southeast_2c_compute_connect" {
  route_table_id = aws_route_table.ap_southeast_2c_compute.id
  destination_cidr_block = "10.13.72.0/21"
}

resource "aws_network_interface" "ap_southeast_2c_compute" {
  subnet_id = aws_subnet.ap_southeast_2c_gateway.id
}

resource "aws_subnet" "ap_southeast_2c_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.64.0/21"
  availability_zone = "ap-southeast-2c"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2c_storage"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2c_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2c_storage"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2c_storage" {
  subnet_id = aws_subnet.ap_southeast_2c_gateway.id
  route_table_id = aws_route_table.ap_southeast_2c_storage.id
}

resource "aws_route" "ap_southeast_2c_storage_compute" {
  route_table_id = aws_route_table.ap_southeast_2c_storage.id
  destination_cidr_block = "10.13.48.0/21"
}

resource "aws_network_interface" "ap_southeast_2c_storage" {
  subnet_id = aws_subnet.ap_southeast_2c_gateway.id
}

resource "aws_subnet" "ap_southeast_2c_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.13.72.0/21"
  availability_zone = "ap-southeast-2c"
  
  tags = {
    env = "front"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2c_connect"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table" "ap_southeast_2c_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "front"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2c_connect"
    build_version = "1.0.0"
    planned = undefined
  }
}

resource "aws_route_table_association" "ap_southeast_2c_connect" {
  subnet_id = aws_subnet.ap_southeast_2c_gateway.id
  route_table_id = aws_route_table.ap_southeast_2c_connect.id
}

resource "aws_route" "ap_southeast_2c_connect_compute" {
  route_table_id = aws_route_table.ap_southeast_2c_connect.id
  destination_cidr_block = "10.13.48.0/21"
}

resource "aws_route" "ap_southeast_2c_connect_outside" {
  route_table_id = aws_route_table.ap_southeast_2c_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ap_southeast_2c_connect" {
  subnet_id = aws_subnet.ap_southeast_2c_gateway.id
}

resource "aws_network_acl" "ap_southeast_2c_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ap_southeast_2c_gateway.id
  ]
  
  tags = {
    env = "front"
    zone = "ap-southeast-2c"
    author = "Lance Pollard"
    region = "ap-southeast-2"
    name = "ap_southeast_2c_gateway"
    build_version = "1.0.0"
    planned = undefined
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
