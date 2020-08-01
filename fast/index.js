
const Moment = require('moment')
const fs = require('fs')
const tierra = require('@lancejpollard/tierra.js')

const buildVersion = require('../package.json').version

const routes = {
  gateway: {
    compute: 'compute'
  },
  compute: {
    storage: 'storage',
    gateway: 'gateway',
    connect: 'connect'
  },
  storage: {
    compute: 'compute'
  },
  connect: {
    compute: 'compute',
    outside: '0.0.0.0/0'
  }
}

const networkACLS = {
  gateway: {
    ingress: [
      {
        protocol: "tcp",
        rule_no: 100,
        action: "allow",
        cidr_block: "0.0.0.0/0",
        from_port: 443,
        to_port: 443
      },
      {
        protocol: "tcp",
        rule_no: 200,
        action: "allow",
        cidr_block: "0.0.0.0/0",
        from_port: 80,
        to_port: 80
      }
    ]
  }
}

const securityGroups = {
  bastion: {
    description: 'Allow SSH into bastion',
    ingress: [
      {
        from_port: 22,
        to_port: 22,
        protocol: 'ssh'
      }
    ]
  },
  network: {
    description: 'Allow SSH into any machine in the network',
    ingress: [
      {
        from_port: 22,
        to_port: 22,
        protocol: 'ssh'
      }
    ]
  },
  message: {
    description: 'Wire up an email server'
  },
  gateway: {
    description: "Allow communication of gateway with internet and compute",
    ingress: [
      {
        from_port: 443,
        to_port: 443,
        protocol: "tcp",
        cidr_blocks: [`0.0.0.0/0`]
      },
      {
        from_port: 80,
        to_port: 80,
        protocol: "tcp",
        cidr_blocks: [`0.0.0.0/0`]
      },
      {
        from_port: 11111,
        to_port: 11111,
        protocol: "tcp",
        cidr_blocks: 'gateway_internal'
      }
    ],
    egress: [
      {
        from_port: 443,
        to_port: 443,
        protocol: "tcp",
        cidr_blocks: [`0.0.0.0/0`]
      },
      {
        from_port: 80,
        to_port: 80,
        protocol: "tcp",
        cidr_blocks: [`0.0.0.0/0`]
      },
      {
        from_port: 11111,
        to_port: 11111,
        protocol: "tcp",
        cidr_blocks: 'gateway_internal'
      }
    ]
  },
  connect: {
    description: "Allow communication of connect nodes",
    ingress: [
      {
        description: 'Communication with internal compute nodes',
        from_port: 11111,
        to_port: 11111,
        protocol: "tcp",
        cidr_blocks: 'connect_internal'
      }
    ],
    egress: [
      {
        description: 'Communication with the external internet',
        from_port: 10000,
        to_port: 10000,
        protocol: "tcp",
        cidr_blocks: [`0.0.0.0/0`]
      },
      {
        description: 'Communication with internal compute nodes',
        from_port: 11111,
        to_port: 11111,
        protocol: "tcp",
        cidr_blocks: 'connect_internal'
      }
    ]
  },
  compute: {
    description: "Allow compute to communicate with internal nodes only",
    ingress: [
      {
        from_port: 11111,
        to_port: 11111,
        protocol: "tcp",
        cidr_blocks: 'compute_internal'
      }
    ],
    egress: [
      {
        from_port: 11111,
        to_port: 11111,
        protocol: "tcp",
        cidr_blocks: 'compute_internal'
      }
    ]
  },
  storage: {
    description: "Allow storage to communicate with compute nodes only",
    ingress: [
      {
        from_port: 11111,
        to_port: 11111,
        protocol: "tcp",
        cidr_blocks: 'storage_internal'
      }
    ],
    egress: [
      {
        from_port: 11111,
        to_port: 11111,
        protocol: "tcp",
        cidr_blocks: 'storage_internal'
      }
    ]
  }
}

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

module.exports = createCloud

function createCloud({
  author,
  domain,
  moment
}) {
  const planned = moment || Moment().format()
  let t = tierra()
  t.terraform({
    blob: {
      required_version: '>= 0.12',
      required_providers: {
        type: 'block',
        blob: [{
          aws: "~> 3.0.0"
        }]
      }
    }
  })

  t.provider({
    name: 'aws',
    blob: {
      region: 'us-west-1'
    }
  })

  createEnvironment({
    env: 'staging',
    cidrOffset: 0,
    t,
    domain,
    author,
    planned
  })
  createEnvironment({
    env: 'production',
    cidrOffset: 64,
    t,
    domain,
    author,
    planned
  })

  t.forEach(blob => {
    if (blob.name) {
      if (!fs.existsSync(`${blob.name}`)) {
        fs.mkdirSync(`${blob.name}`)
      }
      fs.writeFileSync(`${blob.name}/mount.tf`, blob.text)
    } else {
      fs.writeFileSync(`mount.tf`, blob.text)
    }
  })
}

function createEnvironmentModule(env, t) {
  let m = t.module({
    name: env,
    type: env,
    blob: {
      environment: env
    }
  })
  return m
}

function createValue(val) {
  if (typeof val === 'string') {
    return `${val}`
  } else if (typeof val === 'object') {
    throw new Error('oops')
  } else {
    return `${val}`
  }
}

function createEnvironment({
  env,
  cidrOffset,
  t,
  author,
  domain,
  planned
}) {
  let m = createEnvironmentModule(env, t)

  m.variable({
    name: 'environment',
    blob: {
      type: 'string',
      default: env
    }
  })

  let tags = {
    name: 'world',
    build_version: buildVersion,
    env,
    author,
    planned
  }

  createRoute53Zone({
    name: `domain`,
    domain,
    tags,
    m,
    author,
    planned
  })

  createRoute53Record({
    name: `domain_ns`,
    zoneId: `aws_route53_zone.domain.id`,
    domain,
    tags,
    nameservers: [
      'aws_route53_zone.domain.name_servers.0',
      'aws_route53_zone.domain.name_servers.1',
      'aws_route53_zone.domain.name_servers.2',
      'aws_route53_zone.domain.name_servers.3'
    ],
    type: 'NS',
    ttl: 30,
    m,
    author,
    planned
  })

  m.resource({
    type: 'aws_globalaccelerator_accelerator',
    name: 'world',
    blob: {
      name: 'world',
      ip_address_type: 'IPV4',
      enabled: true,
      tags
    }
  })

  m.resource({
    type: 'aws_globalaccelerator_listener',
    name: 'insecure_world',
    blob: {
      accelerator_arn: {
        type: 'key',
        blob: 'aws_globalaccelerator_accelerator.world.id'
      },
      client_affinity: 'NONE',
      protocol: 'TCP',
      port_range: {
        type: 'block',
        blob: [
          {
            from_port: 80,
            to_port: 80
          },
          {
            from_port: 443,
            to_port: 443
          }
        ]
      }
    }
  })

  var endpoint_configuration = []
  Object.keys(config).forEach(region => {
    endpoint_configuration.push({
      endpoint_id: {
        type: 'key',
        blob: `module.${region}.lb_arn`
      },
      weight: 100
    })
  })

  m.resource({
    type: 'aws_globalaccelerator_endpoint_group',
    name: 'insecure_world',
    blob: {
      listener_arn: {
        type: 'key',
        blob: 'aws_globalaccelerator_listener.insecure_world.id'
      },
      endpoint_configuration: {
        type: 'block',
        blob: endpoint_configuration
      }
    }
  })

  Object.keys(config).forEach(region => {
    let m2 = m.module({
      name: region,
      type: region
    })

    createRegion(env, region, {
      environment: env,
      region,
      region_code: config[region].region,
      zones: config[region].zones,
      cidr: config[region].cidr + cidrOffset,
      m2,
      author,
      domain,
      planned
    })
  })
}

function createSecurityGroup({
  name,
  vpcId,
  cidrBlocks,
  group,
  tags,
  m2,
  author,
  domain,
  planned
}) {
  let blob = {}
  let r = {
    type: 'aws_security_group',
    name,
    blob
  }
  if (group.description) {
    blob.description = group.description
  }
  blob.vpc_id = {
    type: 'key',
    blob: vpcId
  }

  if (group.ingress) {
    let ing = []
    group.ingress.forEach(ingress => {
      var cidr = cidrBlocks.ingress[ingress.cidr_blocks] || ingress.cidr_blocks
      ing.push({
        from_port: ingress.from_port,
        to_port: ingress.to_port,
        protocol: ingress.protocol,
        cidr_blocks: cidr
      })
    })
    blob.ingress = {
      type: 'block',
      blob: ing
    }
  }
  if (group.egress) {
    let ing = []
    group.egress.forEach(egress => {
      var cidr = cidrBlocks.egress[egress.cidr_blocks] || egress.cidr_blocks
      ing.push({
        from_port: egress.from_port,
        to_port: egress.to_port,
        protocol: egress.protocol,
        cidr_blocks: cidr
      })
    })
    blob.egress = {
      type: 'block',
      blob: ing
    }
  }
  m2.resource(r)
}

function createRegion(env, region, {
  environment,
  region_code,
  zones,
  cidr,
  m2,
  author,
  domain,
  planned
}) {
  var regionConfig = config[region]
  var regionCode = regionConfig.region
  var zones = regionConfig.zones
  var cidr = regionConfig.cidr
  var cidrBlock = `10.${cidr}.0.0/16`
  var vpcName = `vpc`
  var vpcId = "aws_vpc." + vpcName + ".id"
  m2.provider({
    name: 'aws',
    blob: {
      region: regionCode
    }
  })

  var tags = {
    name: vpcName,
    env,
    region: regionCode,
    author,
    build_version: buildVersion,
    planned
  }

  m2.resource({
    type: 'aws_vpc',
    name: vpcName,
    blob: {
      cidr_block: cidrBlock,
      tags: {
        type: 'map',
        blob: tags
      }
    }
  })

  var subnets = []
  var subnets2 = []
  zones.forEach((zone, i) => {
    var subnetName = [zone, 'gateway'].join('_').replace(/-/g, '_')
    subnets2.push({
      type: 'key',
      blob: `aws_subnet.${subnetName}.id`
    })
  })

  m2.resource({
    type: 'aws_lb',
    name: 'lb',
    blob: {
      name: region,
      internal: false,
      load_balancer_type: 'application',
      enable_http2: true,
      security_groups: [
        {
          type: 'key',
          blob: 'aws_security_group.gateway.id'
        }
      ],
      subnets: subnets2,
      tags: {
        type: 'map',
        blob: tags
      }
    }
  })

  createLoadBalancerTargetGroup({
    name: `${region}_gateway`,
    tags: { ...tags, name: `${region}_gateway` },
    port: 80,
    protocol: 'HTTP',
    vpcId,
    m2,
    author,
    domain,
    planned
  })

  createACMCertificate({
    name: `${region}_gateway`,
    domain,
    tags: { ...tags, name: `${region}_gateway` },
    m2,
    author,
    domain,
    planned
  })

  createLoadBalancerListener({
    name: `${region}_gateway`,
    tags: { ...tags, name: `${region}_gateway` },
    lbArn: `aws_lb.lb.arn`,
    protocol: 'HTTPS',
    port: 443,
    certificateArn: `aws_acm_certificate.${region}_gateway.arn`,
    targetGroupArn: `aws_lb_target_group.${region}_gateway.arn`,
    m2,
    author,
    domain,
    planned
  })

  createInternetGateway({
    name: 'ig',
    vpcId,
    tags: { ...tags, name: `ig` },
    m2,
    author,
    domain,
    planned
  })

  let cidrBlockConfig = {
    ingress: {
      gateway_internal: [
        `10.${cidr}.${0 * 8}.0/21`,
        `10.${cidr}.${4 * 8}.0/21`,
        `10.${cidr}.${8 * 8}.0/21`
      ],
      compute_internal: [
        `10.0.0.0/8`
      ],
      connect_internal: [
        `10.${cidr}.${0 * 8}.0/21`,
        `10.${cidr}.${4 * 8}.0/21`,
        `10.${cidr}.${8 * 8}.0/21`
      ],
      storage_internal: [
        `10.${cidr}.${0 * 8}.0/21`,
        `10.${cidr}.${4 * 8}.0/21`,
        `10.${cidr}.${8 * 8}.0/21`
      ]
    },
    egress: {
      gateway_internal: [
        `10.${cidr}.${0 * 8}.0/21`,
        `10.${cidr}.${4 * 8}.0/21`,
        `10.${cidr}.${8 * 8}.0/21`
      ],
      compute_internal: [
        `10.0.0.0/8`
      ],
      connect_internal: [
        `10.${cidr}.${0 * 8}.0/21`,
        `10.${cidr}.${4 * 8}.0/21`,
        `10.${cidr}.${8 * 8}.0/21`
      ],
      storage_internal: [
        `10.${cidr}.${0 * 8}.0/21`,
        `10.${cidr}.${4 * 8}.0/21`,
        `10.${cidr}.${8 * 8}.0/21`
      ]
    }
  }

  createSecurityGroup({
    name: `gateway`,
    vpcId,
    cidrBlocks: cidrBlockConfig,
    group: securityGroups.gateway,
    tags: { ...tags, name: 'gateway' },
    m2,
    author,
    domain,
    planned
  })

  createSecurityGroup({
    name: `compute`,
    vpcId,
    cidrBlocks: cidrBlockConfig,
    group: securityGroups.compute,
    tags: { ...tags, name: 'compute' },
    m2,
    author,
    domain,
    planned
  })

  createSecurityGroup({
    name: `connect`,
    vpcId,
    cidrBlocks: cidrBlockConfig,
    group: securityGroups.connect,
    tags: { ...tags, name: 'connect' },
    m2,
    author,
    domain,
    planned
  })

  createSecurityGroup({
    name: `storage`,
    vpcId,
    cidrBlocks: cidrBlockConfig,
    group: securityGroups.storage,
    tags: { ...tags, name: 'storage' },
    m2,
    author,
    domain,
    planned
  })

  zones.forEach((zone, i) => {
    createZone({
      region,
      env,
      regionCode,
      zone,
      vpcId,
      cidrBlockConfig,
      cidr: i * 3,
      cidrBlock: `10.${cidr}.{zone}.0/21`,
      m2,
      author,
      domain,
      planned
    })
  })

  m2.output({
    name: 'lb_arn',
    blob: {
      value: {
        type: 'key',
        blob: 'aws_lb.lb.arn'
      }
    }
  })
}

function createInternetGateway({
  name,
  vpcId,
  tags,
  array,
  m2,
  author,
  domain,
  planned
}) {
  m2.resource({
    type: 'aws_internet_gateway',
    name,
    blob: {
      vpc_id: {
        type: 'key',
        blob: vpcId
      },
      tags: {
        type: 'map',
        blob: tags
      }
    }
  })
}

function createZone({
  region,
  env,
  regionCode,
  zone,
  cidr,
  cidrBlock,
  vpcId,
  m2,
  author,
  domain,
  planned
}) {
  var gatewayName = [zone, 'gateway'].join('_').replace(/-/g, '_')
  var computeName = [zone, 'compute'].join('_').replace(/-/g, '_')
  var storageName = [zone, 'storage'].join('_').replace(/-/g, '_')
  var connectName = [zone, 'connect'].join('_').replace(/-/g, '_')
  var gatewayCidrBlock = cidrBlock.replace(/\{zone\}/, (cidr + 1) * 8)
  var computeCidrBlock = cidrBlock.replace(/\{zone\}/, (cidr + 0) * 8)
  var storageCidrBlock = cidrBlock.replace(/\{zone\}/, (cidr + 2) * 8)
  var connectCidrBlock = cidrBlock.replace(/\{zone\}/, (cidr + 3) * 8)

  const cidrBlockConfig = {
    gateway: gatewayCidrBlock,
    compute: computeCidrBlock,
    storage: storageCidrBlock,
    connect: connectCidrBlock
  }

  var subnetId = `aws_subnet.${gatewayName}.id`

  var tags = {
    env,
    zone,
    author,
    region: regionCode,
    name: gatewayName,
    build_version: buildVersion,
    planned
  }

  createNATGateway({
    name: gatewayName,
    subnetId,
    allocationId: `aws_eip.${gatewayName}.id`,
    tags: {
      region: regionCode,
      zone,
      author,
      env,
      build_version: buildVersion,
      planned
    },
    m2,
    author,
    domain,
    planned
  })

  createInstance({
    name: gatewayName,
    networkInterfaceId: `aws_network_interface.${gatewayName}.id`,
    tags,
    m2,
    author,
    domain,
    planned,
    zone,
    subnetId,
    securityGroupIds: [
      `aws_security_group.gateway.id`
    ]
  })

  m2.resource({
    type: 'aws_network_interface',
    name: `${zone.replace(/-/g, '_')}_database`,
    blob: {
      subnet_id: {
        type: 'key',
        blob: subnetId
      }
    }
  })

  createInstance({
    name: `${zone.replace(/-/g, '_')}_database`,
    networkInterfaceId: `aws_network_interface.${zone.replace(/-/g, '_')}_database.id`,
    tags,
    m2,
    author,
    domain,
    planned,
    zone,
    subnetId,
    securityGroupIds: [
      `aws_security_group.storage.id`
    ]
  })

  m2.resource({
    type: 'aws_ebs_volume',
    name: `${zone.replace(/-/g, '_')}_database`,
    blob: {
      availability_zone: zone,
      size: 40,
      tags: {
        type: 'map',
        blob: {
          region: regionCode,
          zone,
          author,
          planned
        }
      }
    }
  })

  m2.resource({
    type: 'aws_volume_attachment',
    name: `${zone.replace(/-/g, '_')}_database`,
    blob: {
      device_name: '/dev/sdh',
      volume_id: {
        type: 'key',
        blob: `aws_ebs_volume.${zone.replace(/-/g, '_')}_database.id`
      },
      instance_id: {
        type: 'key',
        blob: `aws_instance.${zone.replace(/-/g, '_')}_database.id`
      }
    }
  })

  createSubnet({
    type: 'gateway',
    name: gatewayName,
    vpcId,
    zone,
    cidrBlockConfig,
    cidrBlock: gatewayCidrBlock,
    securityGroups: [
      `aws_security_group.gateway.id`
    ],
    subnetId,
    tags,
    m2,
    author,
    domain,
    planned
  })

  createSubnet({
    type: 'compute',
    name: computeName,
    vpcId,
    zone,
    cidrBlockConfig,
    cidrBlock: computeCidrBlock,
    securityGroups: [
      `aws_security_group.compute.id`
    ],
    subnetId,
    tags: {
      ...tags,
      name: computeName
    },
    m2,
    author,
    domain,
    planned
  })

  createSubnet({
    type: 'storage',
    name: storageName,
    vpcId,
    zone,
    cidrBlockConfig,
    cidrBlock: storageCidrBlock,
    securityGroups: [
      `aws_security_group.storage.id`
    ],
    subnetId,
    tags: {
      ...tags,
      name: storageName
    },
    m2,
    author,
    domain,
    planned
  })

  createSubnet({
    type: 'connect',
    name: connectName,
    vpcId,
    zone,
    cidrBlockConfig,
    cidrBlock: connectCidrBlock,
    securityGroups: [
      `aws_security_group.connect.id`
    ],
    subnetId,
    tags: {
      ...tags,
      name: connectName
    },
    m2,
    author,
    domain,
    planned
  })

  Object.keys(networkACLS).forEach(name => {
    let key = `${zone.replace(/-/g, '_')}_${name}`
    createNetworkACL({
      name: key,
      subnetIds: [`aws_subnet.${key}.id`],
      vpcId,
      config: networkACLS[name],
      tags: {
        ...tags,
        name: key
      },
      m2,
      author,
      domain,
      planned
    })
  })
}

function createSubnet({
  type,
  name,
  vpcId,
  subnetId,
  cidrBlock,
  cidrBlockConfig,
  zone,
  securityGroups,
  array,
  tags = {},
  m2,
  author,
  domain,
  planned
}) {
  m2.resource({
    type: 'aws_subnet',
    name,
    blob: {
      vpc_id: {
        type: 'key',
        blob: vpcId
      },
      cidr_block: cidrBlock,
      availability_zone: zone,
      tags: {
        type: 'map',
        blob: tags
      }
    }
  })

  createRouteTable({
    type,
    name,
    tags,
    cidrBlockConfig,
    vpcId,
    subnetId,
    m2,
    author,
    domain,
    planned
  })

  createNetworkInterface({
    name,
    subnetId,
    securityGroups,
    tags,
    m2,
    author,
    domain,
    planned
  })

  createAutoscalingGroup({
    author,
    domain,
    planned
  })
}

function createNATGateway({
  name,
  subnetId,
  allocationId,
  tags = {},
  array,
  m2,
  author,
  domain,
  planned
}) {
  tags = {
    name,
    ...tags
  }

  m2.resource({
    type: 'aws_nat_gateway',
    name,
    blob: {
      subnet_id: {
        type: 'key',
        blob: subnetId
      },
      allocation_id: {
        type: 'key',
        blob: allocationId
      },
      tags: {
        type: 'map',
        blob: tags
      }
    }
  })
}

function createTags(tags) {
  var text = []
  Object.keys(tags).sort().forEach(key => {
    text.push(`    ${key} = "${tags[key]}`)
  })
  return text.join('\n')
}

function createEIP({
  name,
  networkInterfaceId,
  array,
  tags = {},
  m2,
  author,
  domain,
  planned
}) {
  tags = { name, ...tags }
  m2.resource({
    type: 'aws_eip',
    name,
    blob: {
      vpc: true,
      network_interface: {
        type: 'key',
        blob: networkInterfaceId
      },
      tags: {
        type: 'map',
        blob: tags
      }
    }
  })
}

function createNetworkInterface({
  name,
  subnetId,
  securityGroups,
  array,
  tags = {},
  m2,
  author,
  domain,
  planned
}) {
  tags = {
    name,
    ...tags
  }
  m2.resource({
    type: 'aws_network_interface',
    name,
    blob: {
      subnet_id: {
        type: 'key',
        blob: subnetId
      }
    }
  })
}

function createInstance({
  name,
  networkInterfaceId,
  tags,
  array,
  m2,
  author,
  domain,
  planned,
  zone,
  subnetId,
  securityGroupIds = []
}) {
  createEIP({
    name,
    networkInterfaceId,
    tags,
    m2,
    author,
    domain,
    planned
  })

  m2.resource({
    type: 'aws_instance',
    name,
    blob: {
      ami: "ami-0c55b159cbfafe1f0",
      instance_type: 't1.micro',
      availability_zone: zone,
      vpc_security_group_ids: securityGroupIds.map(x => {
        return {
          type: 'key',
          blob: x
        }
      }),
      subnet_id: {
        type: 'key',
        blob: subnetId
      }
    }
  })
}

function createAutoscalingGroup({
  author,
  domain,
  planned
}) {

}

function createNetworkACL({
  name,
  array,
  config,
  subnetIds,
  cidrBlocks = {},
  vpcId,
  tags,
  m2,
  author,
  domain,
  planned
}) {
  let blob = {
    vpc_id: {
      type: 'key',
      blob: vpcId
    },
    subnet_ids: subnetIds.map(x => {
      return {
        type: 'key',
        blob: x
      }
    }),
    tags: {
      type: 'map',
      blob: tags
    }
  }

  if (config.ingress) {
    config.ingress.forEach(ingress => {
      createGress('ingress', ingress)
    })
  }

  if (config.egress) {
    config.egress.forEach(egress => {
      createGress('egress', egress)
    })
  }

  m2.resource({
    type: 'aws_network_acl',
    name,
    blob
  })

  function createGress(type, inputs) {
    var cidr_block = cidrBlocks[inputs.cidr_block] || inputs.cidr_block
    var data = {
      ...inputs,
      cidr_block
    }

    let block = blob[type] = blob[type] || {
      type: 'block',
      blob: []
    }
    let b = {}
    block.blob.push(b)
    Object.keys(data).forEach(key => {
      b[key] = data[key]
    })
  }
}

function createRouteTable({
  array,
  type,
  name,
  subnetId,
  cidrBlockConfig,
  vpcId,
  tags = {},
  m2,
  author,
  domain,
  planned
}) {
  m2.resource({
    type: 'aws_route_table',
    name,
    blob: {
      vpc_id: {
        type: 'key',
        blob: vpcId
      },
      tags: {
        type: 'map',
        blob: tags
      }
    }
  })

  m2.resource({
    type: 'aws_route_table_association',
    name,
    blob: {
      subnet_id: {
        type: 'key',
        blob: subnetId
      },
      route_table_id: {
        type: 'key',
        blob: `aws_route_table.${name}.id`
      }
    }
  })

  Object.keys(routes[type]).forEach(key => {
    createRoute({
      name: `${name}_${key}`,
      array,
      routeTableId: `aws_route_table.${name}.id`,
      cidrBlock: cidrBlockConfig[routes[type][key]] || routes[type][key],
      tags: {
        ...tags,
        type,
        name: `${name}_${key}`
      },
      m2,
      author,
      domain,
      planned
    })
  })
}

function createRoute({
  name,
  array,
  routeTableId,
  cidrBlock,
  tags = {},
  m2,
  author,
  domain,
  planned
}) {
  m2.resource({
    type: 'aws_route',
    name: name,
    blob: {
      route_table_id: {
        type: 'key',
        blob: routeTableId
      },
      destination_cidr_block: cidrBlock
    }
  })
}

function createLoadBalancerListener({
  name,
  array,
  lbArn,
  tags,
  protocol,
  port,
  certificateArn,
  targetGroupArn,
  m2,
  author,
  domain,
  planned
}) {
  m2.resource({
    type: 'aws_lb_listener',
    name,
    blob: {
      load_balancer_arn: {
        type: 'key',
        blob: lbArn
      },
      port: String(port),
      protocol,
      ssl_policy: 'ELBSecurityPolicy-2016-08',
      certificate_arn: {
        type: 'key',
        blob: certificateArn
      },
      default_action: {
        type: 'block',
        blob: [
          {
            type: 'forward',
            target_group_arn: {
              type: 'key',
              blob: targetGroupArn
            }
          }
        ]
      }
    }
  })
}

function createLoadBalancerTargetGroup({
  name,
  port,
  tags,
  array,
  vpcId,
  protocol,
  m2,
  author,
  domain,
  planned
}) {
  m2.resource({
    type: 'aws_lb_target_group',
    name,
    blob: {
      port: String(port),
      protocol,
      vpc_id: {
        type: 'key',
        blob: vpcId
      },
      tags: {
        type: 'map',
        blob: tags
      }
    }
  })
}

function createACMCertificate({
  name,
  domain,
  tags,
  array,
  m2,
  author,
  planned
}) {
  m2.resource({
    type: 'aws_acm_certificate',
    name,
    blob: {
      domain_name: domain,
      validation_method: 'DNS',
      lifecycle: {
        type: 'block',
        blob: [
          {
            create_before_destroy: true
          }
        ]
      },
      tags: {
        type: 'map',
        blob: tags
      }
    }
  })
}

function createRoute53Zone({
  name,
  domain,
  tags,
  m,
  author,
  planned
}) {
  m.resource({
    type: 'aws_route53_zone',
    name,
    blob: {
      name,
      tags: {
        type: 'map',
        blob: tags
      }
    }
  })
}

function createRoute53Record({
  name,
  zoneId,
  domain,
  tags,
  nameservers,
  type,
  ttl,
  m,
  author,
  planned
}) {
  m.resource({
    type: 'aws_route53_record',
    name,
    blob: {
      zone_id: {
        type: 'key',
        blob: zoneId
      },
      name: domain,
      type,
      ttl,
      records: nameservers.map(x => {
        return {
          type: 'key',
          blob: x
        }
      })
    }
  })
}
