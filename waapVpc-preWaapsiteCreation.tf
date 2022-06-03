resource "aws_vpc" "waapVpc" {
  cidr_block           = var.waapVpcCidrBlock
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    "Name" = "${var.prefix}-waapVpc"
  }
}

resource "aws_subnet" "waapVpc-external" {
  vpc_id                  = aws_vpc.waapVpc.id
  count                   = length(var.waapVpc)
  cidr_block              = var.waapVpc[count.index].external_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = var.waapVpc[count.index].az

  tags = {
    Name = "${var.prefix}-waapVpc-external-${var.waapVpc[count.index].name}"
  }
}

resource "aws_subnet" "waapVpc-internal" {
  vpc_id                  = aws_vpc.waapVpc.id
  count                   = length(var.waapVpc)
  cidr_block              = var.waapVpc[count.index].internal_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.waapVpc[count.index].az

  tags = {
    Name = "${var.prefix}-waapVpc-internal-${var.waapVpc[count.index].name}"
  }
}

resource "aws_subnet" "waapVpc-workload" {
  vpc_id                  = aws_vpc.waapVpc.id
  count                   = length(var.waapVpc)
  cidr_block              = var.waapVpc[count.index].workload_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.waapVpc[count.index].az

  tags = {
    Name = "${var.prefix}-waapVpc-workload-${var.waapVpc[count.index].name}"
  }
}

resource "aws_subnet" "waapVpc-ep1" {
  vpc_id                  = aws_vpc.waapVpc.id
  count                   = length(var.waapVpc)
  cidr_block              = var.waapVpc[count.index].ep1_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.waapVpc[count.index].az

  tags = {
    Name = "${var.prefix}-waapVpc-ep1-${var.waapVpc[count.index].name}"
  }
}

resource "aws_subnet" "waapVpc-tgw" {
  vpc_id                  = aws_vpc.waapVpc.id
  count                   = length(var.waapVpc)
  cidr_block              = var.waapVpc[count.index].tgw_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.waapVpc[count.index].az

  tags = {
    Name = "${var.prefix}-waapVpc-tgw-${var.waapVpc[count.index].name}"
  }
}

resource "aws_subnet" "waapVpc-extNlb" {
  vpc_id                  = aws_vpc.waapVpc.id
  count                   = length(var.waapVpc)
  cidr_block              = var.waapVpc[count.index].extNlb_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.waapVpc[count.index].az

  tags = {
    Name = "${var.prefix}-waapVpc-extNlb-${var.waapVpc[count.index].name}"
  }
}

resource "aws_subnet" "waapVpc-intNlb" {
  vpc_id                  = aws_vpc.waapVpc.id
  count                   = length(var.waapVpc)
  cidr_block              = var.waapVpc[count.index].intNlb_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.waapVpc[count.index].az

  tags = {
    Name = "${var.prefix}-waapVpc-intNlb-${var.waapVpc[count.index].name}"
  }
}
