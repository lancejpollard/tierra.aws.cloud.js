
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.4.0.0/16"
  
  tags = {
    name = "vpc"
    env = "production"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_lb" "lb" {
  name = "virginia"
  internal = false
  load_balancer_type = "application"
  enable_http2 = true
  security_groups = [
    aws_security_group.gateway.id
  ]
  subnets = [
    aws_subnet.us_east_1a_gateway.id,
    aws_subnet.us_east_1b_gateway.id,
    aws_subnet.us_east_1c_gateway.id,
    aws_subnet.us_east_1d_gateway.id,
    aws_subnet.us_east_1e_gateway.id,
    aws_subnet.us_east_1f_gateway.id
  ]
  
  tags = {
    name = "vpc"
    env = "production"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_lb_target_group" "virginia_gateway" {
  port = "80"
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "virginia_gateway"
    env = "production"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_acm_certificate" "virginia_gateway" {
  domain_name = "example.com"
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    name = "virginia_gateway"
    env = "production"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_lb_listener" "virginia_gateway" {
  load_balancer_arn = aws_lb.lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.virginia_gateway.arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.virginia_gateway.arn
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "ig"
    env = "production"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
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
      "10.4.0.0/21",
      "10.4.32.0/21",
      "10.4.64.0/21"
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
      "10.4.0.0/21",
      "10.4.32.0/21",
      "10.4.64.0/21"
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
      "10.4.0.0/21",
      "10.4.32.0/21",
      "10.4.64.0/21"
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
      "10.4.0.0/21",
      "10.4.32.0/21",
      "10.4.64.0/21"
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
      "10.4.0.0/21",
      "10.4.32.0/21",
      "10.4.64.0/21"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.4.0.0/21",
      "10.4.32.0/21",
      "10.4.64.0/21"
    ]
  }
}

resource "aws_nat_gateway" "us_east_1a_gateway" {
  subnet_id = aws_subnet.us_east_1a_gateway.id
  allocation_id = aws_eip.us_east_1a_gateway.id
  
  tags = {
    name = "us_east_1a_gateway"
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_eip" "us_east_1a_gateway" {
  vpc = true
  network_interface = aws_network_interface.us_east_1a_gateway.id
  
  tags = {
    name = "us_east_1a_gateway"
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1a_gateway" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1a"
  vpc_security_group_ids = [
    aws_security_group.gateway.id
  ]
  subnet_id = aws_subnet.us_east_1a_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_network_interface" "us_east_1a_database" {
  subnet_id = aws_subnet.us_east_1a_gateway.id
}

resource "aws_eip" "us_east_1a_database" {
  vpc = true
  network_interface = aws_network_interface.us_east_1a_database.id
  
  tags = {
    name = "us_east_1a_gateway"
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1a_database" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1a"
  vpc_security_group_ids = [
    aws_security_group.storage.id
  ]
  subnet_id = aws_subnet.us_east_1a_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_ebs_volume" "us_east_1a_database" {
  availability_zone = "us-east-1a"
  size = 40
  
  tags = {
    region = "us-east-1"
    zone = "us-east-1a"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_volume_attachment" "us_east_1a_database" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.us_east_1a_database.id
  instance_id = aws_instance.us_east_1a_database.id
}

resource "aws_subnet" "us_east_1a_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.8.0/21"
  availability_zone = "us-east-1a"
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1a_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1a_gateway" {
  subnet_id = aws_subnet.us_east_1a_gateway.id
  route_table_id = aws_route_table.us_east_1a_gateway.id
}

resource "aws_route" "us_east_1a_gateway_compute" {
  route_table_id = aws_route_table.us_east_1a_gateway.id
  destination_cidr_block = "10.4.0.0/21"
}

resource "aws_network_interface" "us_east_1a_gateway" {
  subnet_id = aws_subnet.us_east_1a_gateway.id
}

resource "aws_subnet" "us_east_1a_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.0.0/21"
  availability_zone = "us-east-1a"
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1a_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1a_compute" {
  subnet_id = aws_subnet.us_east_1a_gateway.id
  route_table_id = aws_route_table.us_east_1a_compute.id
}

resource "aws_route" "us_east_1a_compute_storage" {
  route_table_id = aws_route_table.us_east_1a_compute.id
  destination_cidr_block = "10.4.16.0/21"
}

resource "aws_route" "us_east_1a_compute_gateway" {
  route_table_id = aws_route_table.us_east_1a_compute.id
  destination_cidr_block = "10.4.8.0/21"
}

resource "aws_route" "us_east_1a_compute_connect" {
  route_table_id = aws_route_table.us_east_1a_compute.id
  destination_cidr_block = "10.4.24.0/21"
}

resource "aws_network_interface" "us_east_1a_compute" {
  subnet_id = aws_subnet.us_east_1a_gateway.id
}

resource "aws_subnet" "us_east_1a_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.16.0/21"
  availability_zone = "us-east-1a"
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1a_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1a_storage" {
  subnet_id = aws_subnet.us_east_1a_gateway.id
  route_table_id = aws_route_table.us_east_1a_storage.id
}

resource "aws_route" "us_east_1a_storage_compute" {
  route_table_id = aws_route_table.us_east_1a_storage.id
  destination_cidr_block = "10.4.0.0/21"
}

resource "aws_network_interface" "us_east_1a_storage" {
  subnet_id = aws_subnet.us_east_1a_gateway.id
}

resource "aws_subnet" "us_east_1a_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.24.0/21"
  availability_zone = "us-east-1a"
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1a_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1a_connect" {
  subnet_id = aws_subnet.us_east_1a_gateway.id
  route_table_id = aws_route_table.us_east_1a_connect.id
}

resource "aws_route" "us_east_1a_connect_compute" {
  route_table_id = aws_route_table.us_east_1a_connect.id
  destination_cidr_block = "10.4.0.0/21"
}

resource "aws_route" "us_east_1a_connect_outside" {
  route_table_id = aws_route_table.us_east_1a_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "us_east_1a_connect" {
  subnet_id = aws_subnet.us_east_1a_gateway.id
}

resource "aws_network_acl" "us_east_1a_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.us_east_1a_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "us-east-1a"
    region = "us-east-1"
    name = "us_east_1a_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
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

resource "aws_nat_gateway" "us_east_1b_gateway" {
  subnet_id = aws_subnet.us_east_1b_gateway.id
  allocation_id = aws_eip.us_east_1b_gateway.id
  
  tags = {
    name = "us_east_1b_gateway"
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_eip" "us_east_1b_gateway" {
  vpc = true
  network_interface = aws_network_interface.us_east_1b_gateway.id
  
  tags = {
    name = "us_east_1b_gateway"
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1b_gateway" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1b"
  vpc_security_group_ids = [
    aws_security_group.gateway.id
  ]
  subnet_id = aws_subnet.us_east_1b_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_network_interface" "us_east_1b_database" {
  subnet_id = aws_subnet.us_east_1b_gateway.id
}

resource "aws_eip" "us_east_1b_database" {
  vpc = true
  network_interface = aws_network_interface.us_east_1b_database.id
  
  tags = {
    name = "us_east_1b_gateway"
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1b_database" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1b"
  vpc_security_group_ids = [
    aws_security_group.storage.id
  ]
  subnet_id = aws_subnet.us_east_1b_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_ebs_volume" "us_east_1b_database" {
  availability_zone = "us-east-1b"
  size = 40
  
  tags = {
    region = "us-east-1"
    zone = "us-east-1b"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_volume_attachment" "us_east_1b_database" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.us_east_1b_database.id
  instance_id = aws_instance.us_east_1b_database.id
}

resource "aws_subnet" "us_east_1b_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.32.0/21"
  availability_zone = "us-east-1b"
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1b_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1b_gateway" {
  subnet_id = aws_subnet.us_east_1b_gateway.id
  route_table_id = aws_route_table.us_east_1b_gateway.id
}

resource "aws_route" "us_east_1b_gateway_compute" {
  route_table_id = aws_route_table.us_east_1b_gateway.id
  destination_cidr_block = "10.4.24.0/21"
}

resource "aws_network_interface" "us_east_1b_gateway" {
  subnet_id = aws_subnet.us_east_1b_gateway.id
}

resource "aws_subnet" "us_east_1b_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.24.0/21"
  availability_zone = "us-east-1b"
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1b_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1b_compute" {
  subnet_id = aws_subnet.us_east_1b_gateway.id
  route_table_id = aws_route_table.us_east_1b_compute.id
}

resource "aws_route" "us_east_1b_compute_storage" {
  route_table_id = aws_route_table.us_east_1b_compute.id
  destination_cidr_block = "10.4.40.0/21"
}

resource "aws_route" "us_east_1b_compute_gateway" {
  route_table_id = aws_route_table.us_east_1b_compute.id
  destination_cidr_block = "10.4.32.0/21"
}

resource "aws_route" "us_east_1b_compute_connect" {
  route_table_id = aws_route_table.us_east_1b_compute.id
  destination_cidr_block = "10.4.48.0/21"
}

resource "aws_network_interface" "us_east_1b_compute" {
  subnet_id = aws_subnet.us_east_1b_gateway.id
}

resource "aws_subnet" "us_east_1b_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.40.0/21"
  availability_zone = "us-east-1b"
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1b_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1b_storage" {
  subnet_id = aws_subnet.us_east_1b_gateway.id
  route_table_id = aws_route_table.us_east_1b_storage.id
}

resource "aws_route" "us_east_1b_storage_compute" {
  route_table_id = aws_route_table.us_east_1b_storage.id
  destination_cidr_block = "10.4.24.0/21"
}

resource "aws_network_interface" "us_east_1b_storage" {
  subnet_id = aws_subnet.us_east_1b_gateway.id
}

resource "aws_subnet" "us_east_1b_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.48.0/21"
  availability_zone = "us-east-1b"
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1b_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1b_connect" {
  subnet_id = aws_subnet.us_east_1b_gateway.id
  route_table_id = aws_route_table.us_east_1b_connect.id
}

resource "aws_route" "us_east_1b_connect_compute" {
  route_table_id = aws_route_table.us_east_1b_connect.id
  destination_cidr_block = "10.4.24.0/21"
}

resource "aws_route" "us_east_1b_connect_outside" {
  route_table_id = aws_route_table.us_east_1b_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "us_east_1b_connect" {
  subnet_id = aws_subnet.us_east_1b_gateway.id
}

resource "aws_network_acl" "us_east_1b_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.us_east_1b_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "us-east-1b"
    region = "us-east-1"
    name = "us_east_1b_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
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

resource "aws_nat_gateway" "us_east_1c_gateway" {
  subnet_id = aws_subnet.us_east_1c_gateway.id
  allocation_id = aws_eip.us_east_1c_gateway.id
  
  tags = {
    name = "us_east_1c_gateway"
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_eip" "us_east_1c_gateway" {
  vpc = true
  network_interface = aws_network_interface.us_east_1c_gateway.id
  
  tags = {
    name = "us_east_1c_gateway"
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1c_gateway" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1c"
  vpc_security_group_ids = [
    aws_security_group.gateway.id
  ]
  subnet_id = aws_subnet.us_east_1c_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_network_interface" "us_east_1c_database" {
  subnet_id = aws_subnet.us_east_1c_gateway.id
}

resource "aws_eip" "us_east_1c_database" {
  vpc = true
  network_interface = aws_network_interface.us_east_1c_database.id
  
  tags = {
    name = "us_east_1c_gateway"
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1c_database" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1c"
  vpc_security_group_ids = [
    aws_security_group.storage.id
  ]
  subnet_id = aws_subnet.us_east_1c_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_ebs_volume" "us_east_1c_database" {
  availability_zone = "us-east-1c"
  size = 40
  
  tags = {
    region = "us-east-1"
    zone = "us-east-1c"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_volume_attachment" "us_east_1c_database" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.us_east_1c_database.id
  instance_id = aws_instance.us_east_1c_database.id
}

resource "aws_subnet" "us_east_1c_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.56.0/21"
  availability_zone = "us-east-1c"
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1c_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1c_gateway" {
  subnet_id = aws_subnet.us_east_1c_gateway.id
  route_table_id = aws_route_table.us_east_1c_gateway.id
}

resource "aws_route" "us_east_1c_gateway_compute" {
  route_table_id = aws_route_table.us_east_1c_gateway.id
  destination_cidr_block = "10.4.48.0/21"
}

resource "aws_network_interface" "us_east_1c_gateway" {
  subnet_id = aws_subnet.us_east_1c_gateway.id
}

resource "aws_subnet" "us_east_1c_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.48.0/21"
  availability_zone = "us-east-1c"
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1c_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1c_compute" {
  subnet_id = aws_subnet.us_east_1c_gateway.id
  route_table_id = aws_route_table.us_east_1c_compute.id
}

resource "aws_route" "us_east_1c_compute_storage" {
  route_table_id = aws_route_table.us_east_1c_compute.id
  destination_cidr_block = "10.4.64.0/21"
}

resource "aws_route" "us_east_1c_compute_gateway" {
  route_table_id = aws_route_table.us_east_1c_compute.id
  destination_cidr_block = "10.4.56.0/21"
}

resource "aws_route" "us_east_1c_compute_connect" {
  route_table_id = aws_route_table.us_east_1c_compute.id
  destination_cidr_block = "10.4.72.0/21"
}

resource "aws_network_interface" "us_east_1c_compute" {
  subnet_id = aws_subnet.us_east_1c_gateway.id
}

resource "aws_subnet" "us_east_1c_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.64.0/21"
  availability_zone = "us-east-1c"
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1c_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1c_storage" {
  subnet_id = aws_subnet.us_east_1c_gateway.id
  route_table_id = aws_route_table.us_east_1c_storage.id
}

resource "aws_route" "us_east_1c_storage_compute" {
  route_table_id = aws_route_table.us_east_1c_storage.id
  destination_cidr_block = "10.4.48.0/21"
}

resource "aws_network_interface" "us_east_1c_storage" {
  subnet_id = aws_subnet.us_east_1c_gateway.id
}

resource "aws_subnet" "us_east_1c_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.72.0/21"
  availability_zone = "us-east-1c"
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1c_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1c_connect" {
  subnet_id = aws_subnet.us_east_1c_gateway.id
  route_table_id = aws_route_table.us_east_1c_connect.id
}

resource "aws_route" "us_east_1c_connect_compute" {
  route_table_id = aws_route_table.us_east_1c_connect.id
  destination_cidr_block = "10.4.48.0/21"
}

resource "aws_route" "us_east_1c_connect_outside" {
  route_table_id = aws_route_table.us_east_1c_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "us_east_1c_connect" {
  subnet_id = aws_subnet.us_east_1c_gateway.id
}

resource "aws_network_acl" "us_east_1c_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.us_east_1c_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "us-east-1c"
    region = "us-east-1"
    name = "us_east_1c_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
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

resource "aws_nat_gateway" "us_east_1d_gateway" {
  subnet_id = aws_subnet.us_east_1d_gateway.id
  allocation_id = aws_eip.us_east_1d_gateway.id
  
  tags = {
    name = "us_east_1d_gateway"
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_eip" "us_east_1d_gateway" {
  vpc = true
  network_interface = aws_network_interface.us_east_1d_gateway.id
  
  tags = {
    name = "us_east_1d_gateway"
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1d_gateway" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1d"
  vpc_security_group_ids = [
    aws_security_group.gateway.id
  ]
  subnet_id = aws_subnet.us_east_1d_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_network_interface" "us_east_1d_database" {
  subnet_id = aws_subnet.us_east_1d_gateway.id
}

resource "aws_eip" "us_east_1d_database" {
  vpc = true
  network_interface = aws_network_interface.us_east_1d_database.id
  
  tags = {
    name = "us_east_1d_gateway"
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1d_database" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1d"
  vpc_security_group_ids = [
    aws_security_group.storage.id
  ]
  subnet_id = aws_subnet.us_east_1d_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_ebs_volume" "us_east_1d_database" {
  availability_zone = "us-east-1d"
  size = 40
  
  tags = {
    region = "us-east-1"
    zone = "us-east-1d"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_volume_attachment" "us_east_1d_database" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.us_east_1d_database.id
  instance_id = aws_instance.us_east_1d_database.id
}

resource "aws_subnet" "us_east_1d_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.80.0/21"
  availability_zone = "us-east-1d"
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1d_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1d_gateway" {
  subnet_id = aws_subnet.us_east_1d_gateway.id
  route_table_id = aws_route_table.us_east_1d_gateway.id
}

resource "aws_route" "us_east_1d_gateway_compute" {
  route_table_id = aws_route_table.us_east_1d_gateway.id
  destination_cidr_block = "10.4.72.0/21"
}

resource "aws_network_interface" "us_east_1d_gateway" {
  subnet_id = aws_subnet.us_east_1d_gateway.id
}

resource "aws_subnet" "us_east_1d_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.72.0/21"
  availability_zone = "us-east-1d"
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1d_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1d_compute" {
  subnet_id = aws_subnet.us_east_1d_gateway.id
  route_table_id = aws_route_table.us_east_1d_compute.id
}

resource "aws_route" "us_east_1d_compute_storage" {
  route_table_id = aws_route_table.us_east_1d_compute.id
  destination_cidr_block = "10.4.88.0/21"
}

resource "aws_route" "us_east_1d_compute_gateway" {
  route_table_id = aws_route_table.us_east_1d_compute.id
  destination_cidr_block = "10.4.80.0/21"
}

resource "aws_route" "us_east_1d_compute_connect" {
  route_table_id = aws_route_table.us_east_1d_compute.id
  destination_cidr_block = "10.4.96.0/21"
}

resource "aws_network_interface" "us_east_1d_compute" {
  subnet_id = aws_subnet.us_east_1d_gateway.id
}

resource "aws_subnet" "us_east_1d_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.88.0/21"
  availability_zone = "us-east-1d"
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1d_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1d_storage" {
  subnet_id = aws_subnet.us_east_1d_gateway.id
  route_table_id = aws_route_table.us_east_1d_storage.id
}

resource "aws_route" "us_east_1d_storage_compute" {
  route_table_id = aws_route_table.us_east_1d_storage.id
  destination_cidr_block = "10.4.72.0/21"
}

resource "aws_network_interface" "us_east_1d_storage" {
  subnet_id = aws_subnet.us_east_1d_gateway.id
}

resource "aws_subnet" "us_east_1d_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.96.0/21"
  availability_zone = "us-east-1d"
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1d_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1d_connect" {
  subnet_id = aws_subnet.us_east_1d_gateway.id
  route_table_id = aws_route_table.us_east_1d_connect.id
}

resource "aws_route" "us_east_1d_connect_compute" {
  route_table_id = aws_route_table.us_east_1d_connect.id
  destination_cidr_block = "10.4.72.0/21"
}

resource "aws_route" "us_east_1d_connect_outside" {
  route_table_id = aws_route_table.us_east_1d_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "us_east_1d_connect" {
  subnet_id = aws_subnet.us_east_1d_gateway.id
}

resource "aws_network_acl" "us_east_1d_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.us_east_1d_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "us-east-1d"
    region = "us-east-1"
    name = "us_east_1d_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
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

resource "aws_nat_gateway" "us_east_1e_gateway" {
  subnet_id = aws_subnet.us_east_1e_gateway.id
  allocation_id = aws_eip.us_east_1e_gateway.id
  
  tags = {
    name = "us_east_1e_gateway"
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_eip" "us_east_1e_gateway" {
  vpc = true
  network_interface = aws_network_interface.us_east_1e_gateway.id
  
  tags = {
    name = "us_east_1e_gateway"
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1e_gateway" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1e"
  vpc_security_group_ids = [
    aws_security_group.gateway.id
  ]
  subnet_id = aws_subnet.us_east_1e_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_network_interface" "us_east_1e_database" {
  subnet_id = aws_subnet.us_east_1e_gateway.id
}

resource "aws_eip" "us_east_1e_database" {
  vpc = true
  network_interface = aws_network_interface.us_east_1e_database.id
  
  tags = {
    name = "us_east_1e_gateway"
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1e_database" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1e"
  vpc_security_group_ids = [
    aws_security_group.storage.id
  ]
  subnet_id = aws_subnet.us_east_1e_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_ebs_volume" "us_east_1e_database" {
  availability_zone = "us-east-1e"
  size = 40
  
  tags = {
    region = "us-east-1"
    zone = "us-east-1e"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_volume_attachment" "us_east_1e_database" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.us_east_1e_database.id
  instance_id = aws_instance.us_east_1e_database.id
}

resource "aws_subnet" "us_east_1e_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.104.0/21"
  availability_zone = "us-east-1e"
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1e_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1e_gateway" {
  subnet_id = aws_subnet.us_east_1e_gateway.id
  route_table_id = aws_route_table.us_east_1e_gateway.id
}

resource "aws_route" "us_east_1e_gateway_compute" {
  route_table_id = aws_route_table.us_east_1e_gateway.id
  destination_cidr_block = "10.4.96.0/21"
}

resource "aws_network_interface" "us_east_1e_gateway" {
  subnet_id = aws_subnet.us_east_1e_gateway.id
}

resource "aws_subnet" "us_east_1e_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.96.0/21"
  availability_zone = "us-east-1e"
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1e_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1e_compute" {
  subnet_id = aws_subnet.us_east_1e_gateway.id
  route_table_id = aws_route_table.us_east_1e_compute.id
}

resource "aws_route" "us_east_1e_compute_storage" {
  route_table_id = aws_route_table.us_east_1e_compute.id
  destination_cidr_block = "10.4.112.0/21"
}

resource "aws_route" "us_east_1e_compute_gateway" {
  route_table_id = aws_route_table.us_east_1e_compute.id
  destination_cidr_block = "10.4.104.0/21"
}

resource "aws_route" "us_east_1e_compute_connect" {
  route_table_id = aws_route_table.us_east_1e_compute.id
  destination_cidr_block = "10.4.120.0/21"
}

resource "aws_network_interface" "us_east_1e_compute" {
  subnet_id = aws_subnet.us_east_1e_gateway.id
}

resource "aws_subnet" "us_east_1e_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.112.0/21"
  availability_zone = "us-east-1e"
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1e_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1e_storage" {
  subnet_id = aws_subnet.us_east_1e_gateway.id
  route_table_id = aws_route_table.us_east_1e_storage.id
}

resource "aws_route" "us_east_1e_storage_compute" {
  route_table_id = aws_route_table.us_east_1e_storage.id
  destination_cidr_block = "10.4.96.0/21"
}

resource "aws_network_interface" "us_east_1e_storage" {
  subnet_id = aws_subnet.us_east_1e_gateway.id
}

resource "aws_subnet" "us_east_1e_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.120.0/21"
  availability_zone = "us-east-1e"
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1e_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1e_connect" {
  subnet_id = aws_subnet.us_east_1e_gateway.id
  route_table_id = aws_route_table.us_east_1e_connect.id
}

resource "aws_route" "us_east_1e_connect_compute" {
  route_table_id = aws_route_table.us_east_1e_connect.id
  destination_cidr_block = "10.4.96.0/21"
}

resource "aws_route" "us_east_1e_connect_outside" {
  route_table_id = aws_route_table.us_east_1e_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "us_east_1e_connect" {
  subnet_id = aws_subnet.us_east_1e_gateway.id
}

resource "aws_network_acl" "us_east_1e_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.us_east_1e_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "us-east-1e"
    region = "us-east-1"
    name = "us_east_1e_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
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

resource "aws_nat_gateway" "us_east_1f_gateway" {
  subnet_id = aws_subnet.us_east_1f_gateway.id
  allocation_id = aws_eip.us_east_1f_gateway.id
  
  tags = {
    name = "us_east_1f_gateway"
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_eip" "us_east_1f_gateway" {
  vpc = true
  network_interface = aws_network_interface.us_east_1f_gateway.id
  
  tags = {
    name = "us_east_1f_gateway"
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1f_gateway" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1f"
  vpc_security_group_ids = [
    aws_security_group.gateway.id
  ]
  subnet_id = aws_subnet.us_east_1f_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_network_interface" "us_east_1f_database" {
  subnet_id = aws_subnet.us_east_1f_gateway.id
}

resource "aws_eip" "us_east_1f_database" {
  vpc = true
  network_interface = aws_network_interface.us_east_1f_database.id
  
  tags = {
    name = "us_east_1f_gateway"
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "us_east_1f_database" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "us-east-1f"
  vpc_security_group_ids = [
    aws_security_group.storage.id
  ]
  subnet_id = aws_subnet.us_east_1f_gateway.id
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_ebs_volume" "us_east_1f_database" {
  availability_zone = "us-east-1f"
  size = 40
  
  tags = {
    region = "us-east-1"
    zone = "us-east-1f"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_volume_attachment" "us_east_1f_database" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.us_east_1f_database.id
  instance_id = aws_instance.us_east_1f_database.id
}

resource "aws_subnet" "us_east_1f_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.128.0/21"
  availability_zone = "us-east-1f"
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1f_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1f_gateway" {
  subnet_id = aws_subnet.us_east_1f_gateway.id
  route_table_id = aws_route_table.us_east_1f_gateway.id
}

resource "aws_route" "us_east_1f_gateway_compute" {
  route_table_id = aws_route_table.us_east_1f_gateway.id
  destination_cidr_block = "10.4.120.0/21"
}

resource "aws_network_interface" "us_east_1f_gateway" {
  subnet_id = aws_subnet.us_east_1f_gateway.id
}

resource "aws_subnet" "us_east_1f_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.120.0/21"
  availability_zone = "us-east-1f"
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1f_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1f_compute" {
  subnet_id = aws_subnet.us_east_1f_gateway.id
  route_table_id = aws_route_table.us_east_1f_compute.id
}

resource "aws_route" "us_east_1f_compute_storage" {
  route_table_id = aws_route_table.us_east_1f_compute.id
  destination_cidr_block = "10.4.136.0/21"
}

resource "aws_route" "us_east_1f_compute_gateway" {
  route_table_id = aws_route_table.us_east_1f_compute.id
  destination_cidr_block = "10.4.128.0/21"
}

resource "aws_route" "us_east_1f_compute_connect" {
  route_table_id = aws_route_table.us_east_1f_compute.id
  destination_cidr_block = "10.4.144.0/21"
}

resource "aws_network_interface" "us_east_1f_compute" {
  subnet_id = aws_subnet.us_east_1f_gateway.id
}

resource "aws_subnet" "us_east_1f_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.136.0/21"
  availability_zone = "us-east-1f"
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1f_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1f_storage" {
  subnet_id = aws_subnet.us_east_1f_gateway.id
  route_table_id = aws_route_table.us_east_1f_storage.id
}

resource "aws_route" "us_east_1f_storage_compute" {
  route_table_id = aws_route_table.us_east_1f_storage.id
  destination_cidr_block = "10.4.120.0/21"
}

resource "aws_network_interface" "us_east_1f_storage" {
  subnet_id = aws_subnet.us_east_1f_gateway.id
}

resource "aws_subnet" "us_east_1f_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.4.144.0/21"
  availability_zone = "us-east-1f"
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "us_east_1f_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "us_east_1f_connect" {
  subnet_id = aws_subnet.us_east_1f_gateway.id
  route_table_id = aws_route_table.us_east_1f_connect.id
}

resource "aws_route" "us_east_1f_connect_compute" {
  route_table_id = aws_route_table.us_east_1f_connect.id
  destination_cidr_block = "10.4.120.0/21"
}

resource "aws_route" "us_east_1f_connect_outside" {
  route_table_id = aws_route_table.us_east_1f_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "us_east_1f_connect" {
  subnet_id = aws_subnet.us_east_1f_gateway.id
}

resource "aws_network_acl" "us_east_1f_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.us_east_1f_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "us-east-1f"
    region = "us-east-1"
    name = "us_east_1f_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
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
