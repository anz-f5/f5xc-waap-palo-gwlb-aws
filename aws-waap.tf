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

resource "aws_subnet" "waapVpc-tsg" {
  vpc_id                  = aws_vpc.waapVpc.id
  count                   = length(var.waapVpc)
  cidr_block              = var.waapVpc[count.index].tsg_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.waapVpc[count.index].az

  tags = {
    Name = "${var.prefix}-waapVpc-tsg-${var.waapVpc[count.index].name}"
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

resource "aws_internet_gateway" "waapVpc-igw" {
  vpc_id = aws_vpc.waapVpc.id

  tags = {
    Name = "${var.prefix}-waapVpc-igw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "waapTsgAttach" {
  subnet_ids         = [for subnet in aws_subnet.waapVpc-tsg : subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id
  vpc_id             = aws_vpc.waapVpc.id

  tags = {
    "Name" = "${var.prefix}-waapVpcTsgAttach"
  }
}

resource "aws_route_table" "waapVpc-internal-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block         = "10.2.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  }

  route {
    cidr_block         = "10.3.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  }

  tags = {
    Name = "${var.prefix}-waapVpc-internal-rt"
  }
}

resource "aws_route_table_association" "waapVpc-internal-association" {
  count          = length(aws_subnet.waapVpc-internal)
  subnet_id      = aws_subnet.waapVpc-internal[count.index].id
  route_table_id = aws_route_table.waapVpc-internal-rt.id
}

resource "aws_route_table" "waapVpc-ingress-rt" {
  vpc_id = aws_vpc.waapVpc.id

  dynamic "route" {
    for_each = var.waapVpc
    content {
      cidr_block      = route.value["extNlb_cidr"]
      vpc_endpoint_id = "vpce-0549d441860da1f96"
    }
  }

  tags = {
    Name = "${var.prefix}-waapVpc-ingress-rt"
  }
}

resource "aws_route_table_association" "waapVpc-ingress-association" {
  route_table_id = aws_route_table.waapVpc-ingress-rt.id
  gateway_id     = aws_internet_gateway.waapVpc-igw.id
}

resource "aws_route_table" "waapVpc-gwlbEp1Az1-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.waapVpc-igw.id
  }

  tags = {
    Name = "${var.prefix}-waapVpc-gwlbEp1Az1-rt"
  }
}

resource "aws_route_table_association" "waapVpc-gwlbEp1Az1-association" {

  subnet_id      = aws_subnet.waapVpc-ep1[0].id
  route_table_id = aws_route_table.waapVpc-gwlbEp1Az1-rt.id
}

