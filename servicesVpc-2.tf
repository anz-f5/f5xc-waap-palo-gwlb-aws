module "vmseries-modules_gwlb" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/gwlb"
  version = "0.2.0"

  name             = "${var.prefix}-servicesVpc-gwlb"
  vpc_id           = aws_vpc.servicesVpc.id
  subnets          = { for az in aws_subnet.servicesVpc-data : az.availability_zone => { "id" : az.id } }
  target_instances = { for index, instance in aws_instance.fwInstance : index => { "id" = instance.id } }

}

module "vmseries-modules_gwlb_ep2" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/gwlb_endpoint_set"
  version = "0.2.0"

  name              = "${var.prefix}-ep2-1"
  gwlb_service_name = module.vmseries-modules_gwlb.endpoint_service.service_name
  vpc_id            = aws_vpc.servicesVpc.id
  subnets           = { for az in aws_subnet.servicesVpc-ep2 : az.availability_zone => { "id" : az.id } }

}

resource "aws_route_table" "servicesVpc-twgSubnet1-rt" {

  depends_on = [
    module.vmseries-modules_gwlb_ep2
  ]

  vpc_id = aws_vpc.servicesVpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep2["next_hop_set"].ids["us-east-1a"]
  }

  tags = {
    Name = "${var.prefix}-servicesVpc-twgSubnet1-rt"
  }
}

resource "aws_route_table_association" "servicesVpc-twgSubnet1-association" {
  subnet_id      = aws_subnet.servicesVpc-tgw[0].id
  route_table_id = aws_route_table.servicesVpc-twgSubnet1-rt.id
}

resource "aws_route_table" "servicesVpc-twgSubnet2-rt" {

  depends_on = [
    module.vmseries-modules_gwlb_ep2
  ]

  vpc_id = aws_vpc.servicesVpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep2["next_hop_set"].ids["us-east-1b"]
  }

  tags = {
    Name = "${var.prefix}-servicesVpc-twgSubnet2-rt"
  }
}

resource "aws_route_table_association" "servicesVpc-twgSubnet2-association" {
  subnet_id      = aws_subnet.servicesVpc-tgw[1].id
  route_table_id = aws_route_table.servicesVpc-twgSubnet2-rt.id
}

resource "aws_route_table" "servicesVpc-twgSubnet3-rt" {

  depends_on = [
    module.vmseries-modules_gwlb_ep2
  ]

  vpc_id = aws_vpc.servicesVpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.vmseries-modules_gwlb_ep2["next_hop_set"].ids["us-east-1c"]
  }

  tags = {
    Name = "${var.prefix}-servicesVpc-twgSubnet3-rt"
  }
}

resource "aws_route_table_association" "servicesVpc-twgSubnet3-association" {
  subnet_id      = aws_subnet.servicesVpc-tgw[2].id
  route_table_id = aws_route_table.servicesVpc-twgSubnet3-rt.id
}
