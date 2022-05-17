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

resource "aws_route_table" "waapVpc-internal-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block         = "0.0.0.0/0"
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

resource "aws_route_table" "waapVpc-intNlb-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  }

  tags = {
    Name = "${var.prefix}-waapVpc-intNlb-rt"
  }
}

resource "aws_route_table_association" "waapVpc-intNlb-association" {
  count          = length(aws_subnet.waapVpc-intNlb)
  subnet_id      = aws_subnet.waapVpc-intNlb[count.index].id
  route_table_id = aws_route_table.waapVpc-intNlb-rt.id
}

resource "aws_route_table" "waapVpc-extNlbAz1-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1a"]
  }

  tags = {
    Name = "${var.prefix}-waapVpc-extNlbAz1-rt"
  }
}

resource "aws_route_table_association" "waapVpc-extNlbAz1-association" {
  subnet_id      = aws_subnet.waapVpc-extNlb[0].id
  route_table_id = aws_route_table.waapVpc-extNlbAz1-rt.id
}

resource "aws_route_table" "waapVpc-extNlbAz2-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1b"]
  }

  tags = {
    Name = "${var.prefix}-waapVpc-extNlbAz2-rt"
  }
}

resource "aws_route_table_association" "waapVpc-extNlbAz2-association" {
  subnet_id      = aws_subnet.waapVpc-extNlb[1].id
  route_table_id = aws_route_table.waapVpc-extNlbAz2-rt.id
}

resource "aws_route_table" "waapVpc-extNlbAz3-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1c"]
  }

  tags = {
    Name = "${var.prefix}-waapVpc-extNlbAz3-rt"
  }
}

resource "aws_route_table_association" "waapVpc-extNlbAz3-association" {
  subnet_id      = aws_subnet.waapVpc-extNlb[2].id
  route_table_id = aws_route_table.waapVpc-extNlbAz3-rt.id
}

resource "aws_route_table" "waapVpc-ingress-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block      = "10.1.50.0/24"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1a"]
  }

  route {
    cidr_block      = "10.1.51.0/24"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1b"]
  }

  route {
    cidr_block      = "10.1.52.0/24"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1c"]
  }

  tags = {
    Name = "${var.prefix}-waapVpc-ingress-rt"
  }
}

resource "aws_route_table_association" "waapVpc-ingress-association" {
  route_table_id = aws_route_table.waapVpc-ingress-rt.id
  gateway_id     = aws_internet_gateway.waapVpc-igw.id
}

resource "aws_route_table" "waapVpc-gwlbEp1-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.waapVpc-igw.id
  }

  tags = {
    Name = "${var.prefix}-waapVpc-gwlbEp1-rt"
  }
}

resource "aws_route_table_association" "waapVpc-gwlbEp1-association" {

  count          = length(aws_subnet.waapVpc-ep1)
  subnet_id      = aws_subnet.waapVpc-ep1[count.index].id
  route_table_id = aws_route_table.waapVpc-gwlbEp1-rt.id
}

