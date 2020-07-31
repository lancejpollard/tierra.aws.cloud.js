
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
  array.push({
    type: 'terraform',
    inputs: {
      required_version: '>= 0.12'
    }
  })

  var array = []
  array.push({
    type: 'provider',
    name: 'aws',
    inputs: {
      region: 'us-west-1'
    }
  })
  Object.keys(config).forEach(region => {
    if (!fs.existsSync(`./${region}`)) {
      fs.mkdirSync(`./${region}`)
    }
  })

  var env = 'check'
  array.push({
    type: 'module',
    name: `${env}`,
    inputs: {
      source: `./check`,
      environment: env
    }
  })
  var env = 'front'
  array.push({
    type: 'module',
    name: `${env}`,
    inputs: {
      source: `./${env}`,
      environment: env
    }
  })
  createEnvironment('check', 0)
  createEnvironment('front', 64)

  fs.writeFileSync('./mount.tf.json', JSON.stringify(compile(array), null, 2))
}

function createEnvironment(env, cidrOffset) {
  var array = []

  array.push({
    type: 'variable',
    name: 'environment',
    inputs: {
      type: 'string',
      default: env
    }
  })
  array.push({
    type: 'resource',
    resource: 'aws_globalaccelerator_accelerator',
    name: 'world',
    inputs: {
      name: 'world',
      ip_address_type: 'IPV4',
      enabled: true
    }
  })
  array.push({
    type: 'resource',
    resource: 'aws_globalaccelerator_listener',
    name: 'world',
    inputs: {
      accelerator_arn: '${aws_globalaccelerator_accelerator.world.id}',
      client_affinity: 'NONE',
      protocol: 'TCP',
      port_range: {
        from_port: 80,
        to_port: 80
      }
    }
  })
  var endpoint_configuration = []
  Object.keys(config).forEach(region => {
    endpoint_configuration.push({
      endpoint_id: '${module.' + region + '.lb_arn}',
      weight: 100
    })
  })

  array.push({
    type: 'resource',
    resource: 'aws_globalaccelerator_endpoint_group',
    name: 'world',
    inputs: {
      listener_arn: '${aws_globalaccelerator_listener.world.id}',
      endpoint_configuration
    }
  })

  Object.keys(config).forEach(region => {
    array.push({
      type: 'module',
      name: region,
      inputs: {
        source: `../${region}`
      }
    })
    createRegion(env, region, {
      environment: env,
      region,
      region_code: config[region].region,
      zones: config[region].zones,
      cidr: config[region].cidr + cidrOffset
    })
  })

  fs.writeFileSync(`./${env}/mount.tj.json`, JSON.stringify(compile(array), null, 2))
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
  var vpcId = "${aws_vpc." + vpcName + ".id}"
  array.push({
    type: 'provider',
    name: 'aws',
    inputs: {
      region: regionCode
    }
  })
  array.push({
    type: 'resource',
    resource: 'aws_vpc',
    name: vpcName,
    inputs: {
      cidr_block: cidrBlock
    }
  })
  var subnets = []
  zones.forEach((zone, i) => {
    var subnetName = [region, zone, 'gateway'].join('_').replace(/-/g, '_')
    subnets.push('${aws_subnet.' + subnetName + '.id}')
  })
  array.push({
    type: 'resource',
    resource: 'aws_lb',
    name: 'lb',
    inputs: {
      name: region,
      internal: false,
      load_balancer_type: 'application',
      security_groups: [
        '${aws_security_group.https.id}'
      ],
      subnets,
      enable_http2: true
    }
  })

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

  array.push({
    type: 'output',
    name: 'lb_arn',
    inputs: {
      value: '${aws_lb.lb.arn}'
    }
  })

  fs.writeFileSync(`./${region}/mount.tf.json`, JSON.stringify(compile(array), null, 2))
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
  var gatewayCidrBlock = cidrBlock.replace(/\{zone\}/, cidr)
  var computeCidrBlock = cidrBlock.replace(/\{zone\}/, cidr + 1)
  var storageCidrBlock = cidrBlock.replace(/\{zone\}/, cidr + 2)

  array.push({
    type: 'resource',
    resource: 'aws_subnet',
    name: gatewayName,
    inputs: {
      vpc_id: vpcId,
      cidr_block: gatewayCidrBlock,
      availability_zone: zone
    }
  })

  array.push({
    type: 'resource',
    resource: 'aws_subnet',
    name: computeName,
    inputs: {
      vpc_id: vpcId,
      cidr_block: computeCidrBlock,
      availability_zone: zone
    }
  })

  array.push({
    type: 'resource',
    resource: 'aws_subnet',
    name: storageName,
    inputs: {
      vpc_id: vpcId,
      cidr_block: storageCidrBlock,
      availability_zone: zone
    }
  })
}
