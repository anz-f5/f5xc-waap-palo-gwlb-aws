data "aws_internet_gateway" "volIgw" {
  filter {
    name   = "attachment.vpc-id"
    values = [aws_vpc.waapVpc.id]
  }
}

resource "aws_route_table" "waapVpc-gwlbEp1-rt" {

  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.volIgw.id
  }

  route {
    cidr_block         = "10.2.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id
  }

  route {
    cidr_block         = "10.3.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id
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

module "vmseries-modules_gwlb_ep1" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/gwlb_endpoint_set"
  version = "0.2.0"

  name              = "${var.prefix}-ep1-1"
  gwlb_service_name = module.vmseries-modules_gwlb.endpoint_service.service_name
  vpc_id            = aws_vpc.waapVpc.id
  subnets           = { for az in aws_subnet.waapVpc-ep1 : az.availability_zone => { "id" : az.id } }

}

resource "aws_route_table" "waapVpc-ingress-rt" {

  depends_on = [
    module.vmseries-modules_gwlb_ep1
  ]

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
  gateway_id     = data.aws_internet_gateway.volIgw.id
}

resource "aws_route_table" "waapVpc-extNlbAz1-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1a"]
  }

  depends_on = [
    module.vmseries-modules_gwlb_ep1
  ]

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

  depends_on = [
    module.vmseries-modules_gwlb_ep1
  ]

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

  depends_on = [
    module.vmseries-modules_gwlb_ep1
  ]

  tags = {
    Name = "${var.prefix}-waapVpc-extNlbAz3-rt"
  }
}

resource "aws_route_table_association" "waapVpc-extNlbAz3-association" {
  subnet_id      = aws_subnet.waapVpc-extNlb[2].id
  route_table_id = aws_route_table.waapVpc-extNlbAz3-rt.id
}

resource "aws_route_table" "waapVpc-ingressInternal-rt" {

  depends_on = [
    module.vmseries-modules_gwlb_ep1
  ]

  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block      = "10.1.60.0/24"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1a"]
  }

  route {
    cidr_block      = "10.1.61.0/24"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1b"]
  }

  route {
    cidr_block      = "10.1.62.0/24"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1c"]
  }

  tags = {
    Name = "${var.prefix}-waapVpc-ingressInternal-rt"
  }
}

resource "aws_route_table_association" "waapVpc-ingressInternal-association" {
  count          = length(aws_subnet.waapVpc-tgw)
  subnet_id      = aws_subnet.waapVpc-tgw[count.index].id
  route_table_id = aws_route_table.waapVpc-ingressInternal-rt.id
}

resource "aws_route_table" "waapVpc-intNlbAz1-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1a"]
  }

  depends_on = [
    module.vmseries-modules_gwlb_ep1
  ]

  tags = {
    Name = "${var.prefix}-waapVpc-intNlbAz1-rt"
  }
}

resource "aws_route_table_association" "waapVpc-intNlbAz1-association" {
  subnet_id      = aws_subnet.waapVpc-intNlb[0].id
  route_table_id = aws_route_table.waapVpc-intNlbAz1-rt.id
}

resource "aws_route_table" "waapVpc-intNlbAz2-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1b"]
  }

  depends_on = [
    module.vmseries-modules_gwlb_ep1
  ]

  tags = {
    Name = "${var.prefix}-waapVpc-intNlbAz2-rt"
  }
}

resource "aws_route_table_association" "waapVpc-intNlbAz2-association" {
  subnet_id      = aws_subnet.waapVpc-intNlb[1].id
  route_table_id = aws_route_table.waapVpc-intNlbAz2-rt.id
}

resource "aws_route_table" "waapVpc-intNlbAz3-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep1["next_hop_set"].ids["us-east-1c"]
  }

  depends_on = [
    module.vmseries-modules_gwlb_ep1
  ]

  tags = {
    Name = "${var.prefix}-waapVpc-intNlbAz3-rt"
  }
}

resource "aws_route_table_association" "waapVpc-intNlbAz3-association" {
  subnet_id      = aws_subnet.waapVpc-intNlb[2].id
  route_table_id = aws_route_table.waapVpc-intNlbAz3-rt.id
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

