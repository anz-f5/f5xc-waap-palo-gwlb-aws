resource "aws_route_table" "servicesVpc-twgSubnet1-rt" {

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
  subnet_id      = aws_subnet.servicesVpc-tsg[0].id
  route_table_id = aws_route_table.servicesVpc-twgSubnet1-rt.id
}

resource "aws_route_table" "servicesVpc-twgSubnet2-rt" {

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
  subnet_id      = aws_subnet.servicesVpc-tsg[1].id
  route_table_id = aws_route_table.servicesVpc-twgSubnet2-rt.id
}

resource "aws_route_table" "servicesVpc-twgSubnet3-rt" {

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
  subnet_id      = aws_subnet.servicesVpc-tsg[2].id
  route_table_id = aws_route_table.servicesVpc-twgSubnet3-rt.id
}
