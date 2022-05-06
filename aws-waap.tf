
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

resource "aws_route_table" "waapVpc-external-rt" {
  vpc_id = aws_vpc.waapVpc.id

  tags = {
    Name = "${var.prefix}-waapVpc-external-rt"
  }
}

resource "aws_route" "waapVpc-internet-route" {
  route_table_id         = aws_route_table.waapVpc-external-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.waapVpc-igw.id
  depends_on             = [aws_route_table.waapVpc-external-rt]
}

resource "aws_route_table_association" "waapVpc-external-association" {
  count          = length(aws_subnet.waapVpc-external)
  subnet_id      = aws_subnet.waapVpc-external[count.index].id
  route_table_id = aws_route_table.waapVpc-external-rt.id
}

resource "aws_internet_gateway" "waapVpc-igw" {
  vpc_id = aws_vpc.waapVpc.id

  tags = {
    Name = "${var.prefix}-waapVpc-igw"
  }
}
