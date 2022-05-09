resource "aws_vpc" "spokeVpc1" {
  cidr_block           = var.spokeVpc1CidrBlock
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    "Name" = "${var.prefix}-spokeVpc1"
  }
}

resource "aws_security_group" "spokeVpc1-sg" {
  name   = "${var.prefix}-spokeVpc1-sg"
  vpc_id = aws_vpc.spokeVpc1.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "spokeVpc1-data" {
  vpc_id                  = aws_vpc.spokeVpc1.id
  count                   = length(var.spokeVpc1)
  cidr_block              = var.spokeVpc1[count.index].data_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.spokeVpc1[count.index].az

  tags = {
    Name = "${var.prefix}-spokeVpc1-data-${var.spokeVpc1[count.index].name}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spokeVpc1TsgAttach" {
  subnet_ids         = [for subnet in aws_subnet.spokeVpc1-data : subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id
  vpc_id             = aws_vpc.spokeVpc1.id

  tags = {
    "Name" = "${var.prefix}-spokeVpc1TsgAttach"
  }
}
