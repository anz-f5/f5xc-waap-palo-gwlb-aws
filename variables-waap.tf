variable "site_disk_size" {
  type        = number
  description = "Disk size in GiB"
  default     = 80
}

variable "meshInstanceType" {
  type        = string
  description = "AWS instance type used for the Volterra site"
  default     = "t3.2xlarge"
}

variable "waapVpcCidrBlock" {
  type        = string
  description = "AWS VPC CIDR, that will be used to create the vpc while creating the site"
  default     = "10.1.0.0/16"
}

variable "waapVpc" {
  description = "Services VPC for waap"
  type        = list(map(string))
  default = [
    { name = "az1", az = "us-east-1a", external_cidr = "10.1.0.0/24", internal_cidr = "10.1.10.0/24", workload_cidr = "10.1.20.0/24", ep1_cidr = "10.1.30.0/24", tgw_cidr = "10.1.40.0/24", extNlb_cidr = "10.1.50.0/24", intNlb_cidr = "10.1.60.0/24" },
    { name = "az2", az = "us-east-1b", external_cidr = "10.1.1.0/24", internal_cidr = "10.1.11.0/24", workload_cidr = "10.1.21.0/24", ep1_cidr = "10.1.31.0/24", tgw_cidr = "10.1.41.0/24", extNlb_cidr = "10.1.51.0/24", intNlb_cidr = "10.1.61.0/24" },
    { name = "az3", az = "us-east-1c", external_cidr = "10.1.2.0/24", internal_cidr = "10.1.12.0/24", workload_cidr = "10.1.22.0/24", ep1_cidr = "10.1.32.0/24", tgw_cidr = "10.1.42.0/24", extNlb_cidr = "10.1.52.0/24", intNlb_cidr = "10.1.62.0/24" }
  ]
}

variable "intNic-filterTags" {
  type = map(string)
  default = {
    "ves.io/interface-type" = "site-local-inside"
    "ves-io-site-name"      = "cz-ce-aws"
  }
}

variable "extNic-filterTags" {
  type = map(string)
  default = {
    "ves.io/interface-type" = "site-local-outside"
    "ves-io-site-name"      = "cz-ce-aws"
  }
}
