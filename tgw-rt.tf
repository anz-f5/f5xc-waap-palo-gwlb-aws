# TGW servicesVpc route table
resource "aws_ec2_transit_gateway_route_table" "tgw-servicesVpc-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  tags = {
    "Name" = "${var.prefix}-tgw-servicesVpc-rt"
  }
}

resource "aws_ec2_transit_gateway_route" "servicesVpctoWaapVpc" {
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.waapVpcTgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-servicesVpc-rt.id
}

resource "aws_ec2_transit_gateway_route" "serviceVpctoSpokeVpc1" {
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc1TgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-servicesVpc-rt.id
}

resource "aws_ec2_transit_gateway_route" "serviceVpctoSpokeVpc2" {
  destination_cidr_block         = "10.3.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc2TgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-servicesVpc-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-serviceVpc-rt-ass" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.servicesTgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-servicesVpc-rt.id
}

# TGW waapVpc route table

resource "aws_ec2_transit_gateway_route_table" "tgw-waapVpc-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  tags = {
    "Name" = "${var.prefix}-tgw-waapVpc-rt"
  }
}

resource "aws_ec2_transit_gateway_route" "waapVpctoSpokeVpc1" {
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc1TgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-waapVpc-rt.id
}

resource "aws_ec2_transit_gateway_route" "waapVpctoSpokeVpc2" {
  destination_cidr_block         = "10.3.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc2TgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-waapVpc-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-waapVpc-rt-ass" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.waapVpcTgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-waapVpc-rt.id
}

# TGW spokeVpc1 route table

resource "aws_ec2_transit_gateway_route_table" "tgw-spokeVpc1-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  tags = {
    "Name" = "${var.prefix}-tgw-spokeVpc1-rt"
  }
}

resource "aws_ec2_transit_gateway_route" "SpokeVpc1toServicesVpc" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.servicesTgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-spokeVpc1-rt.id
}

resource "aws_ec2_transit_gateway_route" "SpokeVpc1toWaapVpc" {
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.waapVpcTgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-spokeVpc1-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-spokeVpc1-rt-ass" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc1TgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-spokeVpc1-rt.id
}

# TGW spokeVpc2 route table

resource "aws_ec2_transit_gateway_route_table" "tgw-spokeVpc2-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  tags = {
    "Name" = "${var.prefix}-tgw-spokeVpc2-rt"
  }
}

resource "aws_ec2_transit_gateway_route" "SpokeVpc2toServicesVpc" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.servicesTgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-spokeVpc2-rt.id
}

resource "aws_ec2_transit_gateway_route" "SpokeVpc2toWaapVpc" {
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.waapVpcTgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-spokeVpc2-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-spokeVpc2-rt-ass" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc2TgwAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-spokeVpc2-rt.id
}


