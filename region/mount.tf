
variable "environment" {
  description = "The environment"
  type = string
}

variable "domain" {
  description = "The domain"
  type = string
}

variable "enabled" {
  description = "If this region is enabled."
  type = bool
}

variable "availability_zone_config" {
  description = "The availability zone config."
  type = map(object({
    min = number
    max = number
  }))
}

variable "region" {
  description = "The human region name"
  type = string
}

variable "region_code" {
  description = "The AWS region"
  type = string
}

variable "cidr_block" {
  description = "The VPC CIDR block"
  type = string
}

variable "availability_zone_list" {
  description = "List of Availability Zones for Region"
  type = list(string)
}

locals {
  vpc_id = concat(
    aws_vpc.vpc.*.id, [""]
  )[0]
  lb = concat(
    aws_lb.lb.*, [""]
  )[0]
  https_sg = concat(
    aws_security_group.https.*.id, [""]
  )[0]
  lb_target_group_arn = concat(
    aws_lb_target_group.front.*.arn, [""]
  )[0]
  acm_certificate_arn = concat(
    aws_acm_certificate.certificate.*.arn, [""]
  )[0]

  default_availability_config = {
    min = 0,
    max = 0
  }
  availability_zone_a = element(
    concat(
      var.availability_zone_list.*, ["", "", "", "", "", ""]
    ),
  0)
  availability_zone_b = element(
    concat(
      var.availability_zone_list.*, ["", "", "", "", "", ""]
    ),
  1)
  availability_zone_c = element(
    concat(
      var.availability_zone_list.*, ["", "", "", "", "", ""]
    ),
  2)
  availability_zone_d = element(
    concat(
      var.availability_zone_list.*, ["", "", "", "", "", ""]
    ),
  3)
  availability_zone_e = element(
    concat(
      var.availability_zone_list.*, ["", "", "", "", "", ""]
    ),
  4)
  availability_zone_f = element(
    concat(
      var.availability_zone_list.*, ["", "", "", "", "", ""]
    ),
  5)
  availability_zone_a_config = contains(
    keys(
      var.availability_zone_config
    ),
    "zone_a"
  ) ? var.availability_zone_config.zone_a : local.default_availability_config
  availability_zone_b_config = contains(
    keys(
      var.availability_zone_config
    ),
    "zone_b"
  ) ? var.availability_zone_config.zone_b : local.default_availability_config
  availability_zone_c_config = contains(
    keys(
      var.availability_zone_config
    ),
    "zone_c"
  ) ? var.availability_zone_config.zone_c : local.default_availability_config
  availability_zone_d_config = contains(
    keys(
      var.availability_zone_config
    ),
    "zone_d"
  ) ? var.availability_zone_config.zone_d : local.default_availability_config
  availability_zone_e_config = contains(
    keys(
      var.availability_zone_config
    ),
    "zone_e"
  ) ? var.availability_zone_config.zone_e : local.default_availability_config
  availability_zone_f_config = contains(
    keys(
      var.availability_zone_config
    ),
    "zone_f"
  ) ? var.availability_zone_config.zone_f : local.default_availability_config
  zone_a_gateway_subnet = module.zone_a.gateway_subnet_id
  gateway_a_cidr_block = cidrsubnet(var.cidr_block, 5, 0)
  compute_a_cidr_block = cidrsubnet(var.cidr_block, 5, 1)
  storage_a_cidr_block = cidrsubnet(var.cidr_block, 5, 2)
  gateway_b_cidr_block = cidrsubnet(var.cidr_block, 5, 3)
  compute_b_cidr_block = cidrsubnet(var.cidr_block, 5, 4)
  storage_b_cidr_block = cidrsubnet(var.cidr_block, 5, 5)
  gateway_c_cidr_block = cidrsubnet(var.cidr_block, 5, 6)
  compute_c_cidr_block = cidrsubnet(var.cidr_block, 5, 7)
  storage_c_cidr_block = cidrsubnet(var.cidr_block, 5, 8)
  gateway_d_cidr_block = cidrsubnet(var.cidr_block, 5, 9)
  compute_d_cidr_block = cidrsubnet(var.cidr_block, 5, 10)
  storage_d_cidr_block = cidrsubnet(var.cidr_block, 5, 11)
  gateway_e_cidr_block = cidrsubnet(var.cidr_block, 5, 12)
  compute_e_cidr_block = cidrsubnet(var.cidr_block, 5, 13)
  storage_e_cidr_block = cidrsubnet(var.cidr_block, 5, 14)
  gateway_f_cidr_block = cidrsubnet(var.cidr_block, 5, 15)
  compute_f_cidr_block = cidrsubnet(var.cidr_block, 5, 16)
  storage_f_cidr_block = cidrsubnet(var.cidr_block, 5, 17)
}

provider "aws" {
  region = var.region_code
}

resource "aws_vpc" "vpc" {
  count = var.enabled ? 1 : 0
  cidr_block = var.cidr_block
}

resource "aws_lb" "lb" {
  count = var.enabled ? 1 : 0
  name = var.region
  internal = false
  load_balancer_type = "application"
  security_groups = [
    local.https_sg,
    # aws_security_group.http.id
  ]
  subnets = [
    local.zone_a_gateway_subnet
  ]
  enable_http2 = true

  tags = {
    environment = var.environment
  }
}

resource "aws_lb_target_group" "front" {
  count = var.enabled ? 1 : 0
  name = var.region
  port = 80
  protocol = "HTTP"
  vpc_id = local.vpc_id
}

resource "aws_lb_listener" "front" {
  count = var.enabled ? 1 : 0
  load_balancer_arn = local.lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = local.acm_certificate_arn

  default_action {
    type = "forward"
    target_group_arn = local.lb_target_group_arn
  }
}

resource "aws_lb_listener" "front_redirect" {
  count = var.enabled ? 1 : 0
  load_balancer_arn = local.lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_acm_certificate" "certificate" {
  count = var.enabled ? 1 : 0
  domain_name = var.domain
  validation_method = "DNS"

  tags = {
    environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_route53_record" "validation" {
#   count = var.enabled ? length(var.subdomain_list) + 1 : 0

#   name = aws_acm_certificate.certificate.domain_validation_options[count.index]["resource_record_name"]
#   type = aws_acm_certificate.certificate.domain_validation_options[count.index]["resource_record_type"]
#   zone_id = var.hosted_zone_id
#   records = [aws_acm_certificate.certificate.domain_validation_options[count.index]["resource_record_value"]]
#   ttl = var.validation_record_ttl
#   allow_overwrite = var.allow_validation_record_overwrite
# }

# resource "aws_acm_certificate_validation" "certificate" {
#   count = var.enabled ? 1 : 0
#   provider = aws.acm_account
#   certificate_arn = aws_acm_certificate.certificate.arn

#   validation_record_fqdns = aws_route53_record.validation.*.fqdn
# }

# resource "aws_route_table" "public" {
#   count = var.enabled ? 1 : 0
#   vpc_id = local.vpc_id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = local.gateway_id
#   }
# }

# resource "aws_internet_gateway" "gateway" {
#   count = var.enabled ? 1 : 0
#   vpc_id = local.vpc_id

#   tags = {
#     name = format("region-gateway-%s", var.region)
#   }
# }

# resource "aws_route_table_association" "a" {
#   subnet_id = aws_subnet.foo.id
#   route_table_id = aws_route_table.bar.id
# }

# resource "aws_network_acl" "public" {
#   count = var.enabled_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? 1 : 0

#   vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
#   subnet_ids = aws_subnet.public.*.id

#   tags = merge(
#     {
#       "Name" = format("%s-${var.public_subnet_suffix}", var.name)
#     },
#     var.tags,
#     var.public_acl_tags,
#   )
# }

# resource "aws_network_acl_rule" "public_inbound" {
#   count = var.enabled_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_inbound_acl_rules) : 0

#   network_acl_id = aws_network_acl.public[0].id

#   egress          = false
#   rule_number     = var.public_inbound_acl_rules[count.index]["rule_number"]
#   rule_action     = var.public_inbound_acl_rules[count.index]["rule_action"]
#   from_port       = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
#   to_port         = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
#   icmp_code       = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
#   icmp_type       = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
#   protocol        = var.public_inbound_acl_rules[count.index]["protocol"]
#   cidr_block      = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
#   ipv6_cidr_block = lookup(var.public_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
# }

# resource "aws_network_acl_rule" "public_outbound" {
#   count = var.enabled_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_outbound_acl_rules) : 0

#   network_acl_id = aws_network_acl.public[0].id

#   egress          = true
#   rule_number     = var.public_outbound_acl_rules[count.index]["rule_number"]
#   rule_action     = var.public_outbound_acl_rules[count.index]["rule_action"]
#   from_port       = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
#   to_port         = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
#   icmp_code       = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
#   icmp_type       = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
#   protocol        = var.public_outbound_acl_rules[count.index]["protocol"]
#   cidr_block      = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
#   ipv6_cidr_block = lookup(var.public_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
# }

module "zone_a" {
  source = "../zone"
  enabled = var.enabled && local.availability_zone_a != "" && local.availability_zone_a_config != local.default_availability_config
  vpc_id = local.vpc_id
  region = var.region
  region_code = var.region_code
  gateway = {
    cidr_block = local.gateway_a_cidr_block,
    availability_zone = local.availability_zone_a
  }
  compute = {
    cidr_block = local.compute_a_cidr_block,
    availability_zone = local.availability_zone_a
  }
  storage = {
    cidr_block = local.storage_a_cidr_block,
    availability_zone = local.availability_zone_a
  }
}

module "zone_b" {
  source = "../zone"
  enabled = var.enabled && local.availability_zone_b != "" && local.availability_zone_b_config != local.default_availability_config
  vpc_id = local.vpc_id
  region = var.region
  region_code = var.region_code
  gateway = {
    cidr_block = local.gateway_b_cidr_block,
    availability_zone = local.availability_zone_b
  }
  compute = {
    cidr_block = local.compute_b_cidr_block,
    availability_zone = local.availability_zone_b
  }
  storage = {
    cidr_block = local.storage_b_cidr_block,
    availability_zone = local.availability_zone_b
  }
}

module "zone_c" {
  source = "../zone"
  enabled = var.enabled && local.availability_zone_c != "" && local.availability_zone_c_config != local.default_availability_config
  vpc_id = local.vpc_id
  region = var.region
  region_code = var.region_code
  gateway = {
    cidr_block = local.gateway_c_cidr_block,
    availability_zone = local.availability_zone_c
  }
  compute = {
    cidr_block = local.compute_c_cidr_block,
    availability_zone = local.availability_zone_c
  }
  storage = {
    cidr_block = local.storage_c_cidr_block,
    availability_zone = local.availability_zone_c
  }
}

module "zone_d" {
  source = "../zone"
  enabled = var.enabled && local.availability_zone_d != "" && local.availability_zone_d_config != local.default_availability_config
  vpc_id = local.vpc_id
  region = var.region
  region_code = var.region_code
  gateway = {
    cidr_block = local.gateway_d_cidr_block,
    availability_zone = local.availability_zone_d
  }
  compute = {
    cidr_block = local.compute_d_cidr_block,
    availability_zone = local.availability_zone_d
  }
  storage = {
    cidr_block = local.storage_d_cidr_block,
    availability_zone = local.availability_zone_d
  }
}

module "zone_e" {
  source = "../zone"
  enabled = var.enabled && local.availability_zone_e != "" && local.availability_zone_e_config != local.default_availability_config
  vpc_id = local.vpc_id
  region = var.region
  region_code = var.region_code
  gateway = {
    cidr_block = local.gateway_e_cidr_block,
    availability_zone = local.availability_zone_e
  }
  compute = {
    cidr_block = local.compute_e_cidr_block,
    availability_zone = local.availability_zone_e
  }
  storage = {
    cidr_block = local.storage_e_cidr_block,
    availability_zone = local.availability_zone_e
  }
}

module "zone_f" {
  source = "../zone"
  enabled = var.enabled && local.availability_zone_f != "" && local.availability_zone_f_config != local.default_availability_config
  vpc_id = local.vpc_id
  region = var.region
  region_code = var.region_code
  gateway = {
    cidr_block = local.gateway_f_cidr_block,
    availability_zone = local.availability_zone_f
  }
  compute = {
    cidr_block = local.compute_f_cidr_block,
    availability_zone = local.availability_zone_f
  }
  storage = {
    cidr_block = local.storage_f_cidr_block,
    availability_zone = local.availability_zone_f
  }
}

resource "aws_security_group" "https" {
  count = var.enabled ? 1 : 0
  name = var.region
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = local.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      local.gateway_a_cidr_block
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = format("region-sg-https-%s", var.region)
  }
}

output "lb" {
  value = local.lb
}

output "enabled" {
  value = var.enabled
}
