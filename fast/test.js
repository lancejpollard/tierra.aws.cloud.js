
const aws = require('.')

aws({
  author: 'Lance Pollard',
  domain: 'example.com',
  moment: '2020-07-31T22:25:32-07:00',
  region: [
    {
      name: 'us-west-1',
      zone: [
        {
          net: 'compute'
        }
      ]
    }
  ]
})
