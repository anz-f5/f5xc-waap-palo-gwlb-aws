variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "api_url" {
  type    = string
  default = "https://f5-apac-ent.console.ves.volterra.io/api"
}

variable "prefix" {
  type        = string
  description = "MCN Name. Also used as a prefix in names of related resources."
  default     = "cz-ce"
}

variable "awsAz1" {
  description = "Availability zone, will dynamically choose one if left empty"
  type        = string
  default     = null
}

variable "awsAz2" {
  description = "Availability zone, will dynamically choose one if left empty"
  type        = string
  default     = null
}

variable "awsAz3" {
  description = "Availability zone, will dynamically choose one if left empty"
  type        = string
  default     = null
}

variable "public_key" {
  description = "Public key string for AWS SSH Key Pair"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCooBbRiFm3UDEty/ch1ZZHKwaTBNBwVJZIDwBuvVjPWnS3RkYMFCGFazIkJJ35QznN2o6nJZb0d8KkakkS7owgJl3ghgEmwfROOFo+EEjT5Y5gbetgs9NGHKVFRnESO3S7PF+Uk/tux4/7ReTyVKBUVfCHpr9I/uwuLHWLO87a88JZSm3qbnhHOdwU4Z8+wxNqk+4qHnvRpCq5HIJxwJoC6IbKvrjDN0YXI7yCG3aIbanSFImbDQE5xFFH+FBRBZlp8ovwajiekZ44BAo+/UJ6/dTjaYTd67a+Sq0i/jngqQ+hVqLVB8S2HQzo9l9JX08KWn92euuBDz+StUO7hIHF Chris@MBP.local"
}