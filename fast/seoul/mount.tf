
provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.11.0.0/16"
  
  tags = {
    name = "vpc"
    env = "production"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_lb" "lb" {
  name = "seoul"
  internal = false
  load_balancer_type = "application"
  enable_http2 = true
  security_groups = [
    aws_security_group.gateway.id
  ]
  subnets = [
    aws_subnet.ap_northeast_2a_gateway.id,
    aws_subnet.ap_northeast_2b_gateway.id,
    aws_subnet.ap_northeast_2c_gateway.id,
    aws_subnet.ap_northeast_2d_gateway.id
  ]
  
  tags = {
    name = "vpc"
    env = "production"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_lb_target_group" "seoul_gateway" {
  port = "80"
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "seoul_gateway"
    env = "production"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_acm_certificate" "seoul_gateway" {
  domain_name = "example.com"
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    name = "seoul_gateway"
    env = "production"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_lb_listener" "seoul_gateway" {
  load_balancer_arn = aws_lb.lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.seoul_gateway.arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.seoul_gateway.arn
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "ig"
    env = "production"
    region = "ap-northeast-2"
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
      "10.11.0.0/21",
      "10.11.32.0/21",
      "10.11.64.0/21"
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
      "10.11.0.0/21",
      "10.11.32.0/21",
      "10.11.64.0/21"
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
      "10.11.0.0/21",
      "10.11.32.0/21",
      "10.11.64.0/21"
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
      "10.11.0.0/21",
      "10.11.32.0/21",
      "10.11.64.0/21"
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
      "10.11.0.0/21",
      "10.11.32.0/21",
      "10.11.64.0/21"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.11.0.0/21",
      "10.11.32.0/21",
      "10.11.64.0/21"
    ]
  }
}

resource "aws_nat_gateway" "ap_northeast_2a_gateway" {
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
  allocation_id = aws_eip.ap_northeast_2a_gateway.id
  
  tags = {
    name = "ap_northeast_2a_gateway"
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_eip" "ap_northeast_2a_gateway" {
  vpc = true
  network_interface = aws_network_interface.ap_northeast_2a_gateway.id
  
  tags = {
    name = "ap_northeast_2a_gateway"
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "ap_northeast_2a_gateway" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "ap-northeast-2a"
  vpc_security_group_ids = [
    aws_security_group.gateway.id
  ]
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_network_interface" "ap_northeast_2a_database" {
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
}

resource "aws_eip" "ap_northeast_2a_database" {
  vpc = true
  network_interface = aws_network_interface.ap_northeast_2a_database.id
  
  tags = {
    name = "ap_northeast_2a_gateway"
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "ap_northeast_2a_database" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "ap-northeast-2a"
  vpc_security_group_ids = [
    aws_security_group.storage.id
  ]
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_ebs_volume" "ap_northeast_2a_database" {
  availability_zone = "ap-northeast-2a"
  size = 40
  
  tags = {
    region = "ap-northeast-2"
    zone = "ap-northeast-2a"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_volume_attachment" "ap_northeast_2a_database" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.ap_northeast_2a_database.id
  instance_id = aws_instance.ap_northeast_2a_database.id
}

resource "aws_subnet" "ap_northeast_2a_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.8.0/21"
  availability_zone = "ap-northeast-2a"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2a_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2a_gateway" {
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
  route_table_id = aws_route_table.ap_northeast_2a_gateway.id
}

resource "aws_route" "ap_northeast_2a_gateway_compute" {
  route_table_id = aws_route_table.ap_northeast_2a_gateway.id
  destination_cidr_block = "10.11.0.0/21"
}

resource "aws_network_interface" "ap_northeast_2a_gateway" {
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
}

resource "aws_subnet" "ap_northeast_2a_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.0.0/21"
  availability_zone = "ap-northeast-2a"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2a_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2a_compute" {
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
  route_table_id = aws_route_table.ap_northeast_2a_compute.id
}

resource "aws_route" "ap_northeast_2a_compute_storage" {
  route_table_id = aws_route_table.ap_northeast_2a_compute.id
  destination_cidr_block = "10.11.16.0/21"
}

resource "aws_route" "ap_northeast_2a_compute_gateway" {
  route_table_id = aws_route_table.ap_northeast_2a_compute.id
  destination_cidr_block = "10.11.8.0/21"
}

resource "aws_route" "ap_northeast_2a_compute_connect" {
  route_table_id = aws_route_table.ap_northeast_2a_compute.id
  destination_cidr_block = "10.11.24.0/21"
}

resource "aws_network_interface" "ap_northeast_2a_compute" {
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
}

resource "aws_subnet" "ap_northeast_2a_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.16.0/21"
  availability_zone = "ap-northeast-2a"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2a_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2a_storage" {
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
  route_table_id = aws_route_table.ap_northeast_2a_storage.id
}

resource "aws_route" "ap_northeast_2a_storage_compute" {
  route_table_id = aws_route_table.ap_northeast_2a_storage.id
  destination_cidr_block = "10.11.0.0/21"
}

resource "aws_network_interface" "ap_northeast_2a_storage" {
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
}

resource "aws_subnet" "ap_northeast_2a_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.24.0/21"
  availability_zone = "ap-northeast-2a"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2a_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2a_connect" {
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
  route_table_id = aws_route_table.ap_northeast_2a_connect.id
}

resource "aws_route" "ap_northeast_2a_connect_compute" {
  route_table_id = aws_route_table.ap_northeast_2a_connect.id
  destination_cidr_block = "10.11.0.0/21"
}

resource "aws_route" "ap_northeast_2a_connect_outside" {
  route_table_id = aws_route_table.ap_northeast_2a_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ap_northeast_2a_connect" {
  subnet_id = aws_subnet.ap_northeast_2a_gateway.id
}

resource "aws_network_acl" "ap_northeast_2a_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ap_northeast_2a_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "ap-northeast-2a"
    region = "ap-northeast-2"
    name = "ap_northeast_2a_gateway"
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

resource "aws_nat_gateway" "ap_northeast_2b_gateway" {
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
  allocation_id = aws_eip.ap_northeast_2b_gateway.id
  
  tags = {
    name = "ap_northeast_2b_gateway"
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_eip" "ap_northeast_2b_gateway" {
  vpc = true
  network_interface = aws_network_interface.ap_northeast_2b_gateway.id
  
  tags = {
    name = "ap_northeast_2b_gateway"
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "ap_northeast_2b_gateway" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "ap-northeast-2b"
  vpc_security_group_ids = [
    aws_security_group.gateway.id
  ]
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_network_interface" "ap_northeast_2b_database" {
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
}

resource "aws_eip" "ap_northeast_2b_database" {
  vpc = true
  network_interface = aws_network_interface.ap_northeast_2b_database.id
  
  tags = {
    name = "ap_northeast_2b_gateway"
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "ap_northeast_2b_database" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "ap-northeast-2b"
  vpc_security_group_ids = [
    aws_security_group.storage.id
  ]
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_ebs_volume" "ap_northeast_2b_database" {
  availability_zone = "ap-northeast-2b"
  size = 40
  
  tags = {
    region = "ap-northeast-2"
    zone = "ap-northeast-2b"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_volume_attachment" "ap_northeast_2b_database" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.ap_northeast_2b_database.id
  instance_id = aws_instance.ap_northeast_2b_database.id
}

resource "aws_subnet" "ap_northeast_2b_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.32.0/21"
  availability_zone = "ap-northeast-2b"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2b_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2b_gateway" {
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
  route_table_id = aws_route_table.ap_northeast_2b_gateway.id
}

resource "aws_route" "ap_northeast_2b_gateway_compute" {
  route_table_id = aws_route_table.ap_northeast_2b_gateway.id
  destination_cidr_block = "10.11.24.0/21"
}

resource "aws_network_interface" "ap_northeast_2b_gateway" {
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
}

resource "aws_subnet" "ap_northeast_2b_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.24.0/21"
  availability_zone = "ap-northeast-2b"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2b_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2b_compute" {
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
  route_table_id = aws_route_table.ap_northeast_2b_compute.id
}

resource "aws_route" "ap_northeast_2b_compute_storage" {
  route_table_id = aws_route_table.ap_northeast_2b_compute.id
  destination_cidr_block = "10.11.40.0/21"
}

resource "aws_route" "ap_northeast_2b_compute_gateway" {
  route_table_id = aws_route_table.ap_northeast_2b_compute.id
  destination_cidr_block = "10.11.32.0/21"
}

resource "aws_route" "ap_northeast_2b_compute_connect" {
  route_table_id = aws_route_table.ap_northeast_2b_compute.id
  destination_cidr_block = "10.11.48.0/21"
}

resource "aws_network_interface" "ap_northeast_2b_compute" {
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
}

resource "aws_subnet" "ap_northeast_2b_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.40.0/21"
  availability_zone = "ap-northeast-2b"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2b_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2b_storage" {
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
  route_table_id = aws_route_table.ap_northeast_2b_storage.id
}

resource "aws_route" "ap_northeast_2b_storage_compute" {
  route_table_id = aws_route_table.ap_northeast_2b_storage.id
  destination_cidr_block = "10.11.24.0/21"
}

resource "aws_network_interface" "ap_northeast_2b_storage" {
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
}

resource "aws_subnet" "ap_northeast_2b_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.48.0/21"
  availability_zone = "ap-northeast-2b"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2b_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2b_connect" {
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
  route_table_id = aws_route_table.ap_northeast_2b_connect.id
}

resource "aws_route" "ap_northeast_2b_connect_compute" {
  route_table_id = aws_route_table.ap_northeast_2b_connect.id
  destination_cidr_block = "10.11.24.0/21"
}

resource "aws_route" "ap_northeast_2b_connect_outside" {
  route_table_id = aws_route_table.ap_northeast_2b_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ap_northeast_2b_connect" {
  subnet_id = aws_subnet.ap_northeast_2b_gateway.id
}

resource "aws_network_acl" "ap_northeast_2b_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ap_northeast_2b_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "ap-northeast-2b"
    region = "ap-northeast-2"
    name = "ap_northeast_2b_gateway"
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

resource "aws_nat_gateway" "ap_northeast_2c_gateway" {
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
  allocation_id = aws_eip.ap_northeast_2c_gateway.id
  
  tags = {
    name = "ap_northeast_2c_gateway"
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_eip" "ap_northeast_2c_gateway" {
  vpc = true
  network_interface = aws_network_interface.ap_northeast_2c_gateway.id
  
  tags = {
    name = "ap_northeast_2c_gateway"
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "ap_northeast_2c_gateway" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "ap-northeast-2c"
  vpc_security_group_ids = [
    aws_security_group.gateway.id
  ]
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_network_interface" "ap_northeast_2c_database" {
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
}

resource "aws_eip" "ap_northeast_2c_database" {
  vpc = true
  network_interface = aws_network_interface.ap_northeast_2c_database.id
  
  tags = {
    name = "ap_northeast_2c_gateway"
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "ap_northeast_2c_database" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "ap-northeast-2c"
  vpc_security_group_ids = [
    aws_security_group.storage.id
  ]
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_ebs_volume" "ap_northeast_2c_database" {
  availability_zone = "ap-northeast-2c"
  size = 40
  
  tags = {
    region = "ap-northeast-2"
    zone = "ap-northeast-2c"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_volume_attachment" "ap_northeast_2c_database" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.ap_northeast_2c_database.id
  instance_id = aws_instance.ap_northeast_2c_database.id
}

resource "aws_subnet" "ap_northeast_2c_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.56.0/21"
  availability_zone = "ap-northeast-2c"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2c_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2c_gateway" {
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
  route_table_id = aws_route_table.ap_northeast_2c_gateway.id
}

resource "aws_route" "ap_northeast_2c_gateway_compute" {
  route_table_id = aws_route_table.ap_northeast_2c_gateway.id
  destination_cidr_block = "10.11.48.0/21"
}

resource "aws_network_interface" "ap_northeast_2c_gateway" {
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
}

resource "aws_subnet" "ap_northeast_2c_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.48.0/21"
  availability_zone = "ap-northeast-2c"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2c_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2c_compute" {
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
  route_table_id = aws_route_table.ap_northeast_2c_compute.id
}

resource "aws_route" "ap_northeast_2c_compute_storage" {
  route_table_id = aws_route_table.ap_northeast_2c_compute.id
  destination_cidr_block = "10.11.64.0/21"
}

resource "aws_route" "ap_northeast_2c_compute_gateway" {
  route_table_id = aws_route_table.ap_northeast_2c_compute.id
  destination_cidr_block = "10.11.56.0/21"
}

resource "aws_route" "ap_northeast_2c_compute_connect" {
  route_table_id = aws_route_table.ap_northeast_2c_compute.id
  destination_cidr_block = "10.11.72.0/21"
}

resource "aws_network_interface" "ap_northeast_2c_compute" {
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
}

resource "aws_subnet" "ap_northeast_2c_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.64.0/21"
  availability_zone = "ap-northeast-2c"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2c_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2c_storage" {
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
  route_table_id = aws_route_table.ap_northeast_2c_storage.id
}

resource "aws_route" "ap_northeast_2c_storage_compute" {
  route_table_id = aws_route_table.ap_northeast_2c_storage.id
  destination_cidr_block = "10.11.48.0/21"
}

resource "aws_network_interface" "ap_northeast_2c_storage" {
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
}

resource "aws_subnet" "ap_northeast_2c_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.72.0/21"
  availability_zone = "ap-northeast-2c"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2c_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2c_connect" {
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
  route_table_id = aws_route_table.ap_northeast_2c_connect.id
}

resource "aws_route" "ap_northeast_2c_connect_compute" {
  route_table_id = aws_route_table.ap_northeast_2c_connect.id
  destination_cidr_block = "10.11.48.0/21"
}

resource "aws_route" "ap_northeast_2c_connect_outside" {
  route_table_id = aws_route_table.ap_northeast_2c_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ap_northeast_2c_connect" {
  subnet_id = aws_subnet.ap_northeast_2c_gateway.id
}

resource "aws_network_acl" "ap_northeast_2c_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ap_northeast_2c_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "ap-northeast-2c"
    region = "ap-northeast-2"
    name = "ap_northeast_2c_gateway"
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

resource "aws_nat_gateway" "ap_northeast_2d_gateway" {
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
  allocation_id = aws_eip.ap_northeast_2d_gateway.id
  
  tags = {
    name = "ap_northeast_2d_gateway"
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_eip" "ap_northeast_2d_gateway" {
  vpc = true
  network_interface = aws_network_interface.ap_northeast_2d_gateway.id
  
  tags = {
    name = "ap_northeast_2d_gateway"
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "ap_northeast_2d_gateway" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "ap-northeast-2d"
  vpc_security_group_ids = [
    aws_security_group.gateway.id
  ]
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_network_interface" "ap_northeast_2d_database" {
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
}

resource "aws_eip" "ap_northeast_2d_database" {
  vpc = true
  network_interface = aws_network_interface.ap_northeast_2d_database.id
  
  tags = {
    name = "ap_northeast_2d_gateway"
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_instance" "ap_northeast_2d_database" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t1.micro"
  availability_zone = "ap-northeast-2d"
  vpc_security_group_ids = [
    aws_security_group.storage.id
  ]
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_ebs_volume" "ap_northeast_2d_database" {
  availability_zone = "ap-northeast-2d"
  size = 40
  
  tags = {
    region = "ap-northeast-2"
    zone = "ap-northeast-2d"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_volume_attachment" "ap_northeast_2d_database" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.ap_northeast_2d_database.id
  instance_id = aws_instance.ap_northeast_2d_database.id
}

resource "aws_subnet" "ap_northeast_2d_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.80.0/21"
  availability_zone = "ap-northeast-2d"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2d_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_gateway"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2d_gateway" {
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
  route_table_id = aws_route_table.ap_northeast_2d_gateway.id
}

resource "aws_route" "ap_northeast_2d_gateway_compute" {
  route_table_id = aws_route_table.ap_northeast_2d_gateway.id
  destination_cidr_block = "10.11.72.0/21"
}

resource "aws_network_interface" "ap_northeast_2d_gateway" {
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
}

resource "aws_subnet" "ap_northeast_2d_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.72.0/21"
  availability_zone = "ap-northeast-2d"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2d_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_compute"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2d_compute" {
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
  route_table_id = aws_route_table.ap_northeast_2d_compute.id
}

resource "aws_route" "ap_northeast_2d_compute_storage" {
  route_table_id = aws_route_table.ap_northeast_2d_compute.id
  destination_cidr_block = "10.11.88.0/21"
}

resource "aws_route" "ap_northeast_2d_compute_gateway" {
  route_table_id = aws_route_table.ap_northeast_2d_compute.id
  destination_cidr_block = "10.11.80.0/21"
}

resource "aws_route" "ap_northeast_2d_compute_connect" {
  route_table_id = aws_route_table.ap_northeast_2d_compute.id
  destination_cidr_block = "10.11.96.0/21"
}

resource "aws_network_interface" "ap_northeast_2d_compute" {
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
}

resource "aws_subnet" "ap_northeast_2d_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.88.0/21"
  availability_zone = "ap-northeast-2d"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2d_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_storage"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2d_storage" {
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
  route_table_id = aws_route_table.ap_northeast_2d_storage.id
}

resource "aws_route" "ap_northeast_2d_storage_compute" {
  route_table_id = aws_route_table.ap_northeast_2d_storage.id
  destination_cidr_block = "10.11.72.0/21"
}

resource "aws_network_interface" "ap_northeast_2d_storage" {
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
}

resource "aws_subnet" "ap_northeast_2d_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.11.96.0/21"
  availability_zone = "ap-northeast-2d"
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ap_northeast_2d_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_connect"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ap_northeast_2d_connect" {
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
  route_table_id = aws_route_table.ap_northeast_2d_connect.id
}

resource "aws_route" "ap_northeast_2d_connect_compute" {
  route_table_id = aws_route_table.ap_northeast_2d_connect.id
  destination_cidr_block = "10.11.72.0/21"
}

resource "aws_route" "ap_northeast_2d_connect_outside" {
  route_table_id = aws_route_table.ap_northeast_2d_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ap_northeast_2d_connect" {
  subnet_id = aws_subnet.ap_northeast_2d_gateway.id
}

resource "aws_network_acl" "ap_northeast_2d_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ap_northeast_2d_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "ap-northeast-2d"
    region = "ap-northeast-2"
    name = "ap_northeast_2d_gateway"
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
