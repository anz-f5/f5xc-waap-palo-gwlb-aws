variable "paloVpcCidrBlock" {
  type        = string
  description = "AWS VPC CIDR, that will be used to create the vpc while creating the site"
  default     = "10.0.0.0/16"
}

variable "servicesVpc" {
  description = "Services VPC Palo add-on"
  type        = list(map(string))
  default = [
    { name = "az1", az = "us-east-1a", data_cidr = "10.0.30.0/24", mgmt_cidr = "10.0.40.0/24" },
    { name = "az2", az = "us-east-1b", data_cidr = "10.0.31.0/24", mgmt_cidr = "10.0.41.0/24" }
  ]
}

variable "firewall_ami_id" {
  description = "VM-Series AMI ID BYOL/Bundle1/Bundle2 for the specified region"
  type        = string
  default     = "ami-0b5bdcb465cdb9d0b"
}

variable "user_data" {
  description = "User Data for VM Series Bootstrapping. Ex. 'type=dhcp-client\nhostname=PANW\nvm-auth-key=0000000000\npanorama-server=<Panorama Server IP>\ntplname=<Panorama Template Stack Name>\ndgname=<Panorama Device Group Name>' or 'vmseries-bootstrap-aws-s3bucket=<s3-bootstrap-bucket-name>'"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type of the web server instances in ASG"
  type        = string
  default     = "m5.xlarge"
}

