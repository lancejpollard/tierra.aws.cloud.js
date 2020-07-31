
const fs = require('fs')

const config = {
  california: {
    region: 'us-west-1',
    zones: ['us-west-1a', 'us-west-1b', 'us-west-1c'],
    cidr: 1
  },
  oregon: {
    region: 'us-west-2',
    zones: ['us-west-2a', 'us-west-2b', 'us-west-2c'],
    cidr: 2
  },
  ohio: {
    region: "us-east-2",
    zones: [
      "us-east-2a",
      "us-east-2b",
      "us-east-2c",
    ],
    cidr: 3
  },
  virginia: {
    region: "us-east-1",
    zones: [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c",
      "us-east-1d",
      "us-east-1e",
      "us-east-1f",
    ],
    cidr: 4
  },
  frankfurt: {
    region: "eu-central-1",
    zones: [
      "eu-central-1a",
      "eu-central-1b",
      "eu-central-1c",
    ],
    cidr: 5
  },
  ireland: {
    region: "eu-west-1",
    zones: [
      "eu-west-1a",
      "eu-west-1b",
      "eu-west-1c",
    ],
    cidr: 6
  },
  london: {
    region: "eu-west-2",
    zones: [
      "eu-west-2a",
      "eu-west-2b",
      "eu-west-2c",
    ],
    cidr: 7
  },
  paris: {
    region: "eu-west-3",
    zones: [
      "eu-west-3a",
      "eu-west-3b",
      "eu-west-3c",
    ],
    cidr: 8
  },
  stockholm: {
    region: "eu-north-1",
    zones: [
      "eu-north-1a",
      "eu-north-1b",
      "eu-north-1c",
    ],
    cidr: 9
  },
  mumbai: {
    region: "ap-south-1",
    zones: [
      "ap-south-1a",
      "ap-south-1b",
      "ap-south-1c",
    ],
    cidr: 10
  },
  seoul: {
    region: "ap-northeast-2",
    zones: [
      "ap-northeast-2a",
      "ap-northeast-2b",
      "ap-northeast-2c",
      "ap-northeast-2d"
    ],
    cidr: 11
  },
  singapore: {
    region: "ap-southeast-1",
    zones: [
      "ap-southeast-1a",
      "ap-southeast-1b",
      "ap-southeast-1c"
    ],
    cidr: 12
  },
  sydney: {
    region: "ap-southeast-2",
    zones: [
      "ap-southeast-2a",
      "ap-southeast-2b",
      "ap-southeast-2c"
    ],
    cidr: 13
  },
  tokyo: {
    region: "ap-northeast-1",
    zones: [
      "ap-northeast-1a",
      "ap-northeast-1c",
      "ap-northeast-1d"
    ],
    cidr: 14
  },
  // sao_paulo: {
  //   region: "sa-east-1",
  //   zones: [
  //     "sa-east-1a",
  //     "sa-east-1b",
  //     "sa-east-1c"
  //   ],
  //   cidr: 15
  // },
  canada: {
    region: "ca-central-1",
    zones: [
      "ca-central-1a",
      "ca-central-1b",
      "ca-central-1d"
    ],
    cidr: 16
  }
}

createCloud()

function compile(array) {
  var json = {}
  array.forEach(item => {
    var object = json[item.type] = json[item.type] || {}
    if (item.resource) {
      var typed = object[item.resource] = object[item.resource] || {}
      var named = typed[item.name] = item.inputs
    } else if (item.name) {
      var named = object[item.name] = item.inputs
    } else {
      json[item.type] = item.inputs
    }
  })
  return json
}

function createCloud() {
  var array = []
  array.push(`
terraform {
  required_version = ">= 0.12"
}`)

  array.push(`
provider "aws" {
  region = "us-west-1"
}`)
  Object.keys(config).forEach(region => {
    if (!fs.existsSync(`./${region}`)) {
      fs.mkdirSync(`./${region}`)
    }
  })

  var env = 'check'
  array.push(`
module "${env}" {
  source = "./${env}"
  environment = "${env}"
}`)
  var env = 'front'
  array.push(`
module "${env}" {
  source = "./${env}"
  environment = "${env}"
}`)
  createEnvironment('check', 0)
  createEnvironment('front', 64)

  fs.writeFileSync('./mount.tf', array.join('\n'))
}

function createEnvironment(env, cidrOffset) {
  var array = []

  array.push(`
variable "environment" {
  type = string
  default = "${env}"
}`)
  array.push(`
resource "aws_globalaccelerator_accelerator" "world" {
  name = "world"
  ip_address_type = "IPV4"
  enabled = true
}`)
  array.push(`
resource "aws_globalaccelerator_listener" "world" {
  accelerator_arn = aws_globalaccelerator_accelerator.world.id
  client_affinity = "NONE"
  protocol = "TCP"
  port_range {
    from_port = 80
    to_port = 80
  }
}`)
  var endpoint_configuration = []
  Object.keys(config).forEach(region => {
    endpoint_configuration.push(`
  endpoint_configuration {
    endpoint_id = module.${region}.lb_arn
    weight = 100
  }`)
  })

  array.push(`
resource "aws_globalaccelerator_endpoint_group" "world" {
  listener_arn = aws_globalaccelerator_listener.world.id
${endpoint_configuration.join('\n')}
}`)

  Object.keys(config).forEach(region => {
    array.push(`
module "${region}" {
  source = "../${region}"
}`)
    createRegion(env, region, {
      environment: env,
      region,
      region_code: config[region].region,
      zones: config[region].zones,
      cidr: config[region].cidr + cidrOffset
    })
  })

  fs.writeFileSync(`./${env}/mount.tf`, array.join('\n'))
}

function createRegion(env, region, {
  environment,
  region_code,
  zones,
  cidr
}) {
  var array = []
  var regionConfig = config[region]
  var regionCode = regionConfig.region
  var zones = regionConfig.zones
  var cidr = regionConfig.cidr
  var cidrBlock = `10.${cidr}.0.0/16`
  var vpcName = region
  var vpcId = "aws_vpc." + vpcName + ".id"
  array.push(`
provider "aws" {
  region = "${regionCode}"
}`)
  array.push(`
resource "aws_vpc" "${vpcName}" {
  cidr_block = "${cidrBlock}"
}`)

  var subnets = []
  zones.forEach((zone, i) => {
    var subnetName = [region, zone, 'gateway'].join('_').replace(/-/g, '_')
    subnets.push('    aws_subnet.' + subnetName + '.id')
  })
  array.push(`
resource "aws_lb" "lb" {
  name = "${region}"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.https.id
  ]
  subnets = [
${subnets.join(',\n')}
  ]
  enable_http2 = true
}`)
  array.push(`
resource "aws_security_group" "https" {
  name = "${region}"
  description = "Allow TLS inbound traffic to the cloud"
  vpc_id = ${vpcId}
  ingress {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "10.${cidr}.0.0/21",
      "10.${cidr}.${3 * 8}.0/21",
      "10.${cidr}.${6 * 8}.0/21"
    ]
  }
  egress {
    description = "Outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}`)

  zones.forEach((zone, i) => {
    createZone({
      region,
      env,
      regionCode,
      zone,
      vpcId,
      cidr: i * 3,
      cidrBlock: `10.${cidr}.{zone}.0/21`
    }, array)
  })

  array.push(`
output "lb_arn" {
  value = aws_lb.lb.arn
}`)

  fs.writeFileSync(`./${region}/mount.tf`, array.join('\n'))
}

function createZone({
  region,
  env,
  regionCode,
  zone,
  cidr,
  cidrBlock,
  vpcId
}, array) {
  var gatewayName = [region, zone, 'gateway'].join('_').replace(/-/g, '_')
  var computeName = [region, zone, 'compute'].join('_').replace(/-/g, '_')
  var storageName = [region, zone, 'storage'].join('_').replace(/-/g, '_')
  var gatewayCidrBlock = cidrBlock.replace(/\{zone\}/, cidr * 8)
  var computeCidrBlock = cidrBlock.replace(/\{zone\}/, (cidr + 1) * 8)
  var storageCidrBlock = cidrBlock.replace(/\{zone\}/, (cidr + 2) * 8)

  array.push(`
resource "aws_subnet" "${gatewayName}" {
  vpc_id = ${vpcId}
  cidr_block = "${gatewayCidrBlock}"
  availability_zone = "${zone}"
}`)

  array.push(`
resource "aws_subnet" "${computeName}" {
  vpc_id = ${vpcId}
  cidr_block = "${computeCidrBlock}"
  availability_zone = "${zone}"
}`)

  array.push(`
resource "aws_subnet" "${storageName}" {
  vpc_id = ${vpcId}
  cidr_block = "${storageCidrBlock}"
  availability_zone = "${zone}"
}`)
}
