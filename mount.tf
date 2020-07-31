
variable "domain" {
  description = "The domain"
  type = string
}

variable "california" {
  description = "Number of California nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {
    zone_a = {
      min = 1,
      max = 1
    }
  }
}

variable "oregon" {
  description = "Number of Oregon nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "ohio" {
  description = "Number of Ohio nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "virginia" {
  description = "Number of Virginia nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "frankfurt" {
  description = "Number of Frankfurt nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "ireland" {
  description = "Number of Ireland nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "london" {
  description = "Number of London nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "milan" {
  description = "Number of Milan nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "paris" {
  description = "Number of Paris nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "stockholm" {
  description = "Number of Stockholm nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "cape_town" {
  description = "Number of Cape Town nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "hong_kong" {
  description = "Number of Hong Kong nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "mumbai" {
  description = "Number of Mumbai nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "osaka" {
  description = "Number of Osaka nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "seoul" {
  description = "Number of Seoul nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "singapore" {
  description = "Number of Singapore nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "sydney" {
  description = "Number of Sydney nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "tokyo" {
  description = "Number of Tokyo nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "sao_paulo" {
  description = "Number of Sao Paulo nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "canada" {
  description = "Number of Canada nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "beijing" {
  description = "Number of Beijing nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "ningxia" {
  description = "Number of Ningxia nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

variable "bahrain" {
  description = "Number of Bahrain nodes"
  type = map(object({
    min = number
    max = number
  }))
  default = {}
}

module "check" {
  source = "./world"
  environment = "check"
  domain = var.domain
  california = var.california
  oregon = var.oregon
  ohio = var.ohio
  virginia = var.virginia
  frankfurt = var.frankfurt
  ireland = var.ireland
  london = var.london
  milan = var.milan
  paris = var.paris
  stockholm = var.stockholm
  cape_town = var.cape_town
  hong_kong = var.hong_kong
  mumbai = var.mumbai
  osaka = var.osaka
  seoul = var.seoul
  singapore = var.singapore
  sydney = var.sydney
  tokyo = var.tokyo
  sao_paulo = var.sao_paulo
  canada = var.canada
  beijing = var.beijing
  ningxia = var.ningxia
  bahrain = var.bahrain
}

module "front" {
  source = "./world"
  environment = "front"
  domain = var.domain
  cidr_block_offset = 64
  california = var.california
  oregon = var.oregon
  ohio = var.ohio
  virginia = var.virginia
  frankfurt = var.frankfurt
  ireland = var.ireland
  london = var.london
  milan = var.milan
  paris = var.paris
  stockholm = var.stockholm
  cape_town = var.cape_town
  hong_kong = var.hong_kong
  mumbai = var.mumbai
  osaka = var.osaka
  seoul = var.seoul
  singapore = var.singapore
  sydney = var.sydney
  tokyo = var.tokyo
  sao_paulo = var.sao_paulo
  canada = var.canada
  beijing = var.beijing
  ningxia = var.ningxia
  bahrain = var.bahrain
}
