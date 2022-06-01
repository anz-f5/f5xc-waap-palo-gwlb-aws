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

resource "aws_ec2_transit_gateway_vpc_attachment" "waapVpcTgwAttach" {
  subnet_ids                                      = [for subnet in aws_subnet.waapVpc-tgw : subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.transitGateway.id
  vpc_id                                          = aws_vpc.waapVpc.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"

  tags = {
    "Name" = "${var.prefix}-waapVpcTgwAttach"
  }
}
