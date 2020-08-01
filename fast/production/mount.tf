
variable "environment" {
  type = string
  default = "production"
}

resource "aws_route53_zone" "domain" {
  name = "domain"
  
  tags = {
    env = "production"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route53_record" "domain_ns" {
  zone_id = aws_route53_zone.domain.id
  name = "example.com"
  type = "NS"
  ttl = 30
  records = [
    aws_route53_zone.domain.name_servers.0,
    aws_route53_zone.domain.name_servers.1,
    aws_route53_zone.domain.name_servers.2,
    aws_route53_zone.domain.name_servers.3
  ]
}

resource "aws_globalaccelerator_accelerator" "world" {
  name = "world"
  ip_address_type = "IPV4"
  enabled = true
  
  tags = {
    env = "production"
    author = "Lance Pollard"
    moment = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_globalaccelerator_listener" "insecure_world" {
  accelerator_arn = aws_globalaccelerator_accelerator.world.id
  client_affinity = "NONE"
  protocol = "TCP"
  
  port_range {
    from_port = 80
    to_port = 80
  }
  
  port_range {
    from_port = 443
    to_port = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "insecure_world" {
  listener_arn = aws_globalaccelerator_listener.insecure_world.id
  
  endpoint_configuration {
    endpoint_id = module.california.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.oregon.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.ohio.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.virginia.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.frankfurt.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.ireland.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.london.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.paris.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.stockholm.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.mumbai.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.seoul.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.singapore.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.sydney.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.tokyo.lb_arn
    weight = 100
  }
  
  endpoint_configuration {
    endpoint_id = module.canada.lb_arn
    weight = 100
  }
}

module "california" {
  source = "../california"
}

module "oregon" {
  source = "../oregon"
}

module "ohio" {
  source = "../ohio"
}

module "virginia" {
  source = "../virginia"
}

module "frankfurt" {
  source = "../frankfurt"
}

module "ireland" {
  source = "../ireland"
}

module "london" {
  source = "../london"
}

module "paris" {
  source = "../paris"
}

module "stockholm" {
  source = "../stockholm"
}

module "mumbai" {
  source = "../mumbai"
}

module "seoul" {
  source = "../seoul"
}

module "singapore" {
  source = "../singapore"
}

module "sydney" {
  source = "../sydney"
}

module "tokyo" {
  source = "../tokyo"
}

module "canada" {
  source = "../canada"
}
