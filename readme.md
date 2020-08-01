
# tierra.aws.cloud.js

This is a Node.js function that generates Terraform configuration files for you to run Terraform on. It makes it so Terraform runs fast on the potentially thousands of resources it creates, as opposed to using fancy syntax features of the Terraform script, which break down quickly both in terms of performance and capability.

https://ec2instances.info/

```
npm install @lancejpollard/tierra.aws.cloud.js
```

Run the following to generate a Terraform file tree in the current directory that will create one server. Perhaps call this file `form.js`.

```js
const aws = require('@lancejpollard/tierra.aws.cloud.js')

aws({
  author: 'Lance Pollard',
  domain: 'example.com',
  design: '1.0.0',
  region: 'us-west-1',
  branch: 'production',
  device: 't1.micro',
  system: 'ami-08a73e98905090559',
  moment: '2020-07-31T22:25:32-07:00',
  server: 1,
  bucket: 1,
  caller: 0
})
```

Run this to create 1 server in each region across the network:

```js
aws({
  author: 'Lance Pollard',
  domain: 'example.com',
  region: ['us-west-1', 'us-east-1', ...],
  device: 't1.micro',
  system: 'ami-08a73e98905090559',
  moment: '2020-07-31T22:25:32-07:00'
})
```

```js
aws({
  author: 'Lance Pollard',
  domain: 'example.com',
  region: [
    {
      source: 'us-west-1',
      sector: [
        {
          source: 'us-west-1a',
          bottom: 1,
          summit: 4,
          device: 't1.micro',
          system: 'ami-08a73e98905090559'
        }
      ]
    }
  ],
  moment: '2020-07-31T22:25:32-07:00'
})
```

```js
aws({
  author: 'Lance Pollard',
  domain: 'example.com',
  region: [
    {
      source: 'us-west-1',
      branch: [
        {
          source: 'us-west-1a',
          device: 't1.micro',
          system: 'ami-08a73e98905090559',
          server: {
            bottom: 1,
            summit: 4
          },
          bucket: 1
        }
      ]
    }
  ],
  moment: '2020-07-31T22:25:32-07:00'
})
```

```
node form
terraform init
terraform plan
# terraform apply # generates the actual resources
```

Install Terraform with Homebrew on a Mac, or Choco on Windows.

```
brew install terraform
```

```
choco install terraform
```

## TODO

- [ ] Autoscaling Groups
- [ ] [Launch Templates](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template)
- [ ] Health Checks
- [ ] IAM Roles
- [ ] Email Server
- [ ] EBS Volumes
- [ ] Instances
- [ ] Policies
- [ ] Bastion
- [ ] Logging
- [ ] Monitoring
- [ ] AMI
- [ ] [VPN Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway)
- [ ] [VPC Peering Connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection)
- [ ] [VPC Connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection)
- [ ] Flow Log
- [ ] HSM
- [ ] [ACM Certificate Validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation)
- [ ] S3

Trying to keep this low-level and use only the lowest-level features, instead of things like RDS (managed database service) and Kubernetes and tons of other things.

## License

MIT
