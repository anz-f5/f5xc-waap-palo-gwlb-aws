variable "spokeVpc1CidrBlock" {
  type        = string
  description = "AWS VPC CIDR, that will be used to create the vpc while creating the site"
  default     = "10.2.0.0/16"
}

variable "spokeVpc1" {
  description = "spokeVpc1"
  type        = list(map(string))
  default = [
    { name = "az1", az = "us-east-1a", data_cidr = "10.2.0.0/24", tgw_cidr = "10.2.1.0/24" }
  ]
}
