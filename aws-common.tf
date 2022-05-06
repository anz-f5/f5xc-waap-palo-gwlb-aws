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

resource "aws_ec2_transit_gateway" "transitGateway" {
  tags = {
    "Name" = "${var.prefix}-tsg"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "waapTsgAttach" {
  subnet_ids         = [for subnet in aws_subnet.waapVpc-external : subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id
  vpc_id             = aws_vpc.waapVpc.id

  tags = {
    "Name" = "${var.prefix}-waapVpcTsgAttach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "servicesTsgAttach" {
  subnet_ids         = [for subnet in aws_subnet.servicesVpc-data : subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id
  vpc_id             = aws_vpc.servicesVpc.id

  tags = {
    "Name" = "${var.prefix}-servicesVpcTsgAttach"
  }
}
