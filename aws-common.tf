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

# Create TWG
resource "aws_ec2_transit_gateway" "transitGateway" {

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"

  tags = {
    "Name" = "${var.prefix}-tgw"
  }
}

# Create TGW attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "servicesTsgAttach" {
  subnet_ids                                      = [for subnet in aws_subnet.servicesVpc-tsg : subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.transitGateway.id
  vpc_id                                          = aws_vpc.servicesVpc.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"

  tags = {
    "Name" = "${var.prefix}-servicesVpcTsgAttach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spokeVpc1TsgAttach" {
  subnet_ids                                      = [for subnet in aws_subnet.spokeVpc1-tsg : subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.transitGateway.id
  vpc_id                                          = aws_vpc.spokeVpc1.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"

  tags = {
    "Name" = "${var.prefix}-spokeVpc1TsgAttach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spokeVpc2TsgAttach" {
  subnet_ids                                      = [for subnet in aws_subnet.spokeVpc2-tsg : subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.transitGateway.id
  vpc_id                                          = aws_vpc.spokeVpc2.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"

  tags = {
    "Name" = "${var.prefix}-spokeVpc2TsgAttach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "waapVpcTsgAttach" {
  subnet_ids                                      = [for subnet in aws_subnet.waapVpc-tsg : subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.transitGateway.id
  vpc_id                                          = aws_vpc.waapVpc.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"

  tags = {
    "Name" = "${var.prefix}-waapVpcTsgAttach"
  }
}

# TGW serviceVpc route table
resource "aws_ec2_transit_gateway_route_table" "tgw-servicesVpc-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  tags = {
    "Name" = "${var.prefix}-tgw-servicesVpc-rt"
  }
}

resource "aws_ec2_transit_gateway_route" "servicesVpctoWaapVpc" {
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.waapVpcTsgAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-servicesVpc-rt.id
}

resource "aws_ec2_transit_gateway_route" "serviceVpctoSpokeVpc1" {
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc1TsgAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-servicesVpc-rt.id
}

resource "aws_ec2_transit_gateway_route" "serviceVpctoSpokeVpc2" {
  destination_cidr_block         = "10.3.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc2TsgAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-servicesVpc-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-serviceVpc-rt-ass" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.servicesTsgAttach.id
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
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc1TsgAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-waapVpc-rt.id
}

resource "aws_ec2_transit_gateway_route" "waapVpctoSpokeVpc2" {
  destination_cidr_block         = "10.3.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc2TsgAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-waapVpc-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-waapVpc-rt-ass" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.waapVpcTsgAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-waapVpc-rt.id
}

# TGW spokeVpc1 route table

resource "aws_ec2_transit_gateway_route_table" "tgw-spokeVpc1-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  tags = {
    "Name" = "${var.prefix}-tgw-spokeVpc1-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-spokeVpc1-rt-ass" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc1TsgAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-spokeVpc1-rt.id
}

# TGW spokeVpc2 route table

resource "aws_ec2_transit_gateway_route_table" "tgw-spokeVpc2-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  tags = {
    "Name" = "${var.prefix}-tgw-spokeVpc2-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-spokeVpc2-rt-ass" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spokeVpc2TsgAttach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-spokeVpc2-rt.id
}


