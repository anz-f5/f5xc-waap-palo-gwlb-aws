data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_key_pair" "ssh-keypair" {
  key_name   = "${var.prefix}-ssh-key"
  public_key = var.public_key
}

locals {
  awsName = format("%s-aws", var.prefix)
  awsAz1  = var.awsAz1 != null ? var.awsAz1 : data.aws_availability_zones.available.names[0]
  awsAz2  = var.awsAz2 != null ? var.awsAz1 : data.aws_availability_zones.available.names[1]
  awsAz3  = var.awsAz3 != null ? var.awsAz1 : data.aws_availability_zones.available.names[2]
}
