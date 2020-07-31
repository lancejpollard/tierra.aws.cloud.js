
variable "environment" {
  description = "The environment"
  type = string
}

variable "domain" {
  description = "The domain"
  type = string
}

variable "cidr_block" {
  description = "The Network CIDR block"
  type = string
  default = "10.0.0.0/8"
}

variable "cidr_block_offset" {
  description = "The Network CIDR block offset"
  type = number
  default = 0
}

variable "california" {
  description = "Number of California nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "oregon" {
  description = "Number of Oregon nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "ohio" {
  description = "Number of Ohio nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "virginia" {
  description = "Number of Virginia nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "frankfurt" {
  description = "Number of Frankfurt nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "ireland" {
  description = "Number of Ireland nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "london" {
  description = "Number of London nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "milan" {
  description = "Number of Milan nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "paris" {
  description = "Number of Paris nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "stockholm" {
  description = "Number of Stockholm nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "cape_town" {
  description = "Number of Cape Town nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "hong_kong" {
  description = "Number of Hong Kong nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "mumbai" {
  description = "Number of Mumbai nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "osaka" {
  description = "Number of Osaka nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "seoul" {
  description = "Number of Seoul nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "singapore" {
  description = "Number of Singapore nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "sydney" {
  description = "Number of Sydney nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "tokyo" {
  description = "Number of Tokyo nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "sao_paulo" {
  description = "Number of Sao Paulo nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "canada" {
  description = "Number of Canada nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "beijing" {
  description = "Number of Beijing nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "ningxia" {
  description = "Number of Ningxia nodes"
  type = map(object({
    min = number
    max = number
  }))
}

variable "bahrain" {
  description = "Number of Bahrain nodes"
  type = map(object({
    min = number
    max = number
  }))
}

locals {
  management_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 0
  )
  california_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 1
  )
  oregon_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 2
  )
  ohio_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 3
  )
  virginia_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 4
  )
  frankfurt_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 5
  )
  ireland_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 6
  )
  london_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 7
  )
  milan_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 8
  )
  paris_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 9
  )
  stockholm_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 10
  )
  cape_town_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 11
  )
  hong_kong_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 12
  )
  mumbai_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 13
  )
  osaka_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 14
  )
  seoul_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 15
  )
  singapore_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 16
  )
  sydney_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 17
  )
  tokyo_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 18
  )
  sao_paulo_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 19
  )
  canada_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 20
  )
  beijing_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 21
  )
  ningxia_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 22
  )
  bahrain_cidr_block = cidrsubnet(
    var.cidr_block, 8, var.cidr_block_offset + 23
  )

  california_enabled = length(keys(var.california)) > 0
  oregon_enabled = length(keys(var.oregon)) > 0
  ohio_enabled = length(keys(var.ohio)) > 0
  virginia_enabled = length(keys(var.virginia)) > 0
  frankfurt_enabled = length(keys(var.frankfurt)) > 0
  ireland_enabled = length(keys(var.ireland)) > 0
  london_enabled = length(keys(var.london)) > 0
  paris_enabled = length(keys(var.paris)) > 0
  stockholm_enabled = length(keys(var.stockholm)) > 0
  mumbai_enabled = length(keys(var.mumbai)) > 0
  seoul_enabled = length(keys(var.seoul)) > 0
  singapore_enabled = length(keys(var.singapore)) > 0
  sydney_enabled = length(keys(var.sydney)) > 0
  tokyo_enabled = length(keys(var.tokyo)) > 0
  sao_paulo_enabled = length(keys(var.sao_paulo)) > 0
  canada_enabled = length(keys(var.canada)) > 0

  ipv4 = "IPV4"
  tcp = "TCP"
}

resource "aws_globalaccelerator_accelerator" "world" {
  name = "world"
  ip_address_type = local.ipv4
  enabled = true
}

resource "aws_globalaccelerator_listener" "world" {
  accelerator_arn = aws_globalaccelerator_accelerator.world.id
  client_affinity = "NONE"
  protocol = local.tcp

  port_range {
    from_port = 80
    to_port = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "world" {
  listener_arn = aws_globalaccelerator_listener.world.id

  dynamic "endpoint_configuration" {
    for_each = [
      for mod in [
        module.california,
        module.oregon,
        module.ohio,
        module.virginia,
        module.frankfurt,
        module.ireland,
        module.london,
        # module.milan,
        module.paris,
        module.stockholm,
        # module.cape_town,
        # module.hong_kong,
        module.mumbai,
        # module.osaka,
        module.seoul,
        module.singapore,
        module.sydney,
        # module.tokyo,
        # module.sao_paulo,
        module.canada,
        # module.beijing,
        # module.ningxia,
        # module.bahrain,
      ]:
      mod.lb
      if mod.enabled
    ]
    iterator = lb
    content {
      endpoint_id = lb.value["arn"]
      weight = 100
    }
  }
}

# resource "aws_ses_domain_identity" "domain" {
#   domain = var.domain
# }

# resource "aws_route53_record" "email_domain_verification" {
#   zone_id = "ABCDEFGHIJ123"
#   name    = "_amazonses.example.com"
#   type    = "TXT"
#   ttl     = "60"
#   records = [aws_ses_domain_identity.domain.verification_token]
# }

# resource "aws_route53_record" "example_ses_domain_mail_from_txt" {
#   zone_id = "${aws_route53_zone.example.id}"
#   name    = "${aws_ses_domain_mail_from.example.mail_from_domain}"
#   type    = "TXT"
#   ttl     = "600"
#   records = ["v=spf1 include:amazonses.com -all"]
# }

# resource "aws_ses_domain_mail_from" "example" {
#   domain = "${aws_ses_domain_identity.example.domain}"
#   mail_from_domain = "bounce.${aws_ses_domain_identity.example.domain}"
# }

# aws_autoscaling_attachment
# aws_autoscaling_group
# aws_autoscaling_lifecycle_hook
# aws_autoscaling_notification
# aws_autoscaling_policy
# aws_autoscaling_schedule
# aws_cloudhsm_v2_cluster
# aws_cloudhsm_v2_hsm
# aws_cloudtrail
# aws_cloudwatch_dashboard
# aws_cloudwatch_event_permission
# aws_cloudwatch_event_rule
# aws_cloudwatch_event_target
# aws_cloudwatch_log_destination
# aws_cloudwatch_log_destination_policy
# aws_cloudwatch_log_group
# aws_cloudwatch_log_metric_filter
# aws_cloudwatch_log_resource_policy
# aws_cloudwatch_log_stream
# aws_cloudwatch_log_subscription_filter
# aws_cloudwatch_metric_alarm
# aws_ami
# aws_flow_log
# aws_network_acl
# aws_network_acl_rule
# aws_security_group
# aws_security_group_rule
# aws_s3_access_point
# aws_s3_account_public_access_block
# aws_s3_bucket
# aws_s3_bucket_analytics_configuration
# aws_s3_bucket_inventory
# aws_s3_bucket_metric
# aws_s3_bucket_notification
# aws_s3_bucket_object
# aws_s3_bucket_policy
# aws_s3_bucket_public_access_block
# aws_db_cluster_snapshot
# aws_db_event_subscription
# aws_db_instance
# aws_db_instance_role_association
# aws_db_option_group
# aws_db_parameter_group
# aws_db_security_group
# aws_db_snapshot
# aws_db_subnet_group
# aws_rds_cluster
# aws_rds_cluster_endpoint
# aws_rds_cluster_instance
# aws_rds_cluster_parameter_group
# aws_rds_global_cluster
# aws_instance
# aws_key_pair
# aws_ssm_activation
# aws_ssm_association
# aws_ssm_document
# aws_ssm_maintenance_window
# aws_ssm_maintenance_window_target
# aws_ssm_maintenance_window_task
# aws_ssm_parameter
# aws_ssm_patch_baseline
# aws_ssm_patch_group
# aws_ssm_resource_data_sync
# aws_sqs_queue
# aws_sqs_queue_policy
# aws_launch_configuration
# aws_launch_template
# aws_placement_group
# aws_volume_attachment
# aws_ecs_capacity_provider
# aws_ecs_cluster
# aws_ecs_service
# aws_ecs_task_definition
# aws_lb_listener_certificate
# aws_lb_listener_rule
# aws_lb_target_group
# aws_lb_target_group_attachment
# aws_iam_access_key
# aws_iam_account_alias
# aws_iam_account_password_policy
# aws_iam_group
# aws_iam_group_membership
# aws_iam_group_policy
# aws_iam_group_policy_attachment
# aws_iam_instance_profile
# aws_iam_openid_connect_provider
# aws_iam_policy
# aws_iam_policy_attachment
# aws_iam_role
# aws_iam_role_policy
# aws_iam_role_policy_attachment
# aws_iam_saml_provider
# aws_iam_server_certificate
# aws_iam_service_linked_role
# aws_iam_user
# aws_iam_user_group_membership
# aws_iam_user_login_profile
# aws_iam_user_policy
# aws_iam_user_policy_attachment
# aws_iam_user_ssh_key
# aws_kms_alias
# aws_kms_ciphertext
# aws_kms_external_key
# aws_kms_grant
# aws_kms_key
# aws_ses_active_receipt_rule_set
# aws_ses_configuration_set
# aws_ses_domain_dkim
# aws_ses_event_destination
# aws_ses_identity_notification_topic
# aws_ses_identity_policy
# aws_ses_receipt_filter
# aws_ses_receipt_rule
# aws_ses_receipt_rule_set
# aws_ses_template

module "california" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.california_enabled
  region = "california"
  region_code = "us-west-1"
  availability_zone_config = var.california
  cidr_block = local.california_cidr_block
  availability_zone_list = [
    "us-west-1a",
    "us-west-1b",
    "us-west-1c"
  ]
}

module "oregon" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.oregon_enabled
  region = "oregon"
  region_code = "us-west-2"
  availability_zone_config = var.oregon
  cidr_block = local.oregon_cidr_block
  availability_zone_list = [
    "us-west-2a",
    "us-west-2b",
    "us-west-2c"
  ]
}

module "ohio" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.ohio_enabled
  region = "ohio"
  region_code = "us-east-2"
  availability_zone_config = var.ohio
  cidr_block = local.ohio_cidr_block
  availability_zone_list = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c",
  ]
}

module "virginia" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.virginia_enabled
  region = "virginia"
  region_code = "us-east-1"
  availability_zone_config = var.virginia
  cidr_block = local.virginia_cidr_block
  availability_zone_list = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1e",
    "us-east-1f",
  ]
}

module "frankfurt" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.frankfurt_enabled
  region = "frankfurt"
  region_code = "eu-central-1"
  availability_zone_config = var.frankfurt
  cidr_block = local.frankfurt_cidr_block
  availability_zone_list = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c",
  ]
}

module "ireland" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.ireland_enabled
  region = "ireland"
  region_code = "eu-west-1"
  availability_zone_config = var.ireland
  cidr_block = local.ireland_cidr_block
  availability_zone_list = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c",
  ]
}

module "london" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.london_enabled
  region = "london"
  region_code = "eu-west-2"
  availability_zone_config = var.london
  cidr_block = local.london_cidr_block
  availability_zone_list = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c",
  ]
}

# module "milan" {
#   source = "../region"
# environment = var.environment
# domain = var.domain
#   region = "milan"
#   region_code = "eu-south-1"
#   enabled = var.milan.enabled
#   min = var.milan.min
#   max = var.milan.max
#   cidr_block = local.milan_cidr_block
#   availability_zone_list = [

#   ]
# }

module "paris" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.paris_enabled
  region = "paris"
  region_code = "eu-west-3"
  availability_zone_config = var.paris
  cidr_block = local.paris_cidr_block
  availability_zone_list = [
    "eu-west-3a",
    "eu-west-3b",
    "eu-west-3c",
  ]
}

module "stockholm" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.stockholm_enabled
  region = "stockholm"
  region_code = "eu-north-1"
  availability_zone_config = var.stockholm
  cidr_block = local.stockholm_cidr_block
  availability_zone_list = [
    "eu-north-1a",
    "eu-north-1b",
    "eu-north-1c",
  ]
}

# module "cape_town" {
#   source = "../region"
#   region = "cape_town"
#   region_code = "af-south-1"
#   enabled = var.cape_town.enabled
#   min = var.cape_town.min
#   max = var.cape_town.max
#   cidr_block = local.cape_town_cidr_block
#   availability_zone_list = [

#   ]
# }

# module "hong_kong" {
#   source = "../region"
#   region = "hong_kong"
#   region_code = "ap-east-1"
#   enabled = var.hong_kong.enabled
#   min = var.hong_kong.min
#   max = var.hong_kong.max
#   cidr_block = local.hong_kong_cidr_block
#   availability_zone_list = [

#   ]
# }

module "mumbai" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.mumbai_enabled
  region = "mumbai"
  region_code = "ap-south-1"
  availability_zone_config = var.mumbai
  cidr_block = local.mumbai_cidr_block
  availability_zone_list = [
    "ap-south-1a",
    "ap-south-1b",
    "ap-south-1c",
  ]
}

# module "osaka" {
#   source = "../region"
#   region = "osaka"
#   region_code = "ap-northeast-3"
#   enabled = var.osaka.enabled
#   min = var.osaka.min
#   max = var.osaka.max
#   cidr_block = local.osaka_cidr_block
#   availability_zone_list = [

#   ]
# }

module "seoul" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.seoul_enabled
  region = "seoul"
  region_code = "ap-northeast-2"
  availability_zone_config = var.seoul
  cidr_block = local.seoul_cidr_block
  availability_zone_list = [
    "ap-northeast-2a",
    "ap-northeast-2b",
    "ap-northeast-2c",
    "ap-northeast-2d"
  ]
}

module "singapore" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.singapore_enabled
  region = "singapore"
  region_code = "ap-southeast-1"
  availability_zone_config = var.singapore
  cidr_block = local.singapore_cidr_block
  availability_zone_list = [
    "ap-southeast-1a",
    "ap-southeast-1b",
    "ap-southeast-1c"
  ]
}

module "sydney" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.sydney_enabled
  region = "sydney"
  region_code = "ap-southeast-2"
  availability_zone_config = var.sydney
  cidr_block = local.sydney_cidr_block
  availability_zone_list = [
    "ap-southeast-2a",
    "ap-southeast-2b",
    "ap-southeast-2c"
  ]
}

module "tokyo" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.tokyo_enabled
  region = "tokyo"
  region_code = "ap-northeast-1"
  availability_zone_config = var.tokyo
  cidr_block = local.tokyo_cidr_block
  availability_zone_list = [
    "ap-northeast-1a",
    "ap-northeast-1c",
    "ap-northeast-1d"
  ]
}

module "sao_paulo" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.sao_paulo_enabled
  region = "sao_paulo"
  region_code = "sa-east-1"
  availability_zone_config = var.sao_paulo
  cidr_block = local.sao_paulo_cidr_block
  availability_zone_list = [
    "sa-east-1a",
    "sa-east-1b",
    "sa-east-1c"
  ]
}

module "canada" {
  source = "../region"
  environment = var.environment
  domain = var.domain
  enabled = local.canada_enabled
  region = "canada"
  region_code = "ca-central-1"
  availability_zone_config = var.canada
  cidr_block = local.canada_cidr_block
  availability_zone_list = [
    "ca-central-1a",
    "ca-central-1b",
    "ca-central-1d"
  ]
}

# module "beijing" {
#   source = "../region"
#   region = "beijing"
#   region_code = "cn-north-1"
#   enabled = var.beijing.enabled
#   min = var.beijing.min
#   max = var.beijing.max
#   cidr_block = local.beijing_cidr_block
#   availability_zone_list = [

#   ]
# }

# module "ningxia" {
#   source = "../region"
#   region = "ningxia"
#   region_code = "cn-northwest-1"
#   enabled = var.ningxia.enabled
#   min = var.ningxia.min
#   max = var.ningxia.max
#   cidr_block = local.ningxia_cidr_block
#   availability_zone_list = [

#   ]
# }

# module "bahrain" {
#   source = "../region"
#   region = "bahrain"
#   region_code = "me-south-1"
#   enabled = var.bahrain.enabled
#   min = var.bahrain.min
#   max = var.bahrain.max
#   cidr_block = local.bahrain_cidr_block
#   availability_zone_list = [

#   ]
# }
