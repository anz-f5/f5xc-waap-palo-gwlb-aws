resource "aws_vpc" "spokeVpc2" {
  cidr_block           = var.spokeVpc2CidrBlock
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    "Name" = "${var.prefix}-spokeVpc2"
  }
}

resource "aws_security_group" "spokeVpc2-sg" {
  name   = "${var.prefix}-spokeVpc2-sg"
  vpc_id = aws_vpc.spokeVpc2.id

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

resource "aws_subnet" "spokeVpc2-data" {
  vpc_id                  = aws_vpc.spokeVpc2.id
  count                   = length(var.spokeVpc2)
  cidr_block              = var.spokeVpc2[count.index].data_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.spokeVpc2[count.index].az

  tags = {
    Name = "${var.prefix}-spokeVpc2-data-${var.spokeVpc2[count.index].name}"
  }
}

resource "aws_subnet" "spokeVpc2-tsg" {
  vpc_id                  = aws_vpc.spokeVpc2.id
  count                   = length(var.spokeVpc2)
  cidr_block              = var.spokeVpc2[count.index].tsg_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.spokeVpc2[count.index].az

  tags = {
    Name = "${var.prefix}-spokeVpc2-tsg-${var.spokeVpc2[count.index].name}"
  }
}

module "spokeVpc2-ec2Instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                   = "${var.prefix}-spokeVpc2Ubuntu1"
  count                  = length(var.spokeVpc2)
  ami                    = "ami-0c4f7023847b90238"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh-keypair.key_name
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.spokeVpc2-sg.id]
  subnet_id              = aws_subnet.spokeVpc2-data[count.index].id
}

resource "aws_route_table" "spokeVpc2-main-rt" {
  vpc_id = aws_vpc.spokeVpc2.id

  tags = {
    Name = "${var.prefix}-spokeVpc2-main-rt"
  }
}

resource "aws_route" "spokeVpc2-default-route" {
  route_table_id         = aws_route_table.spokeVpc2-main-rt.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.transitGateway.id
}

resource "aws_route_table_association" "spokeVpc2-main-association" {
  count          = length(aws_subnet.spokeVpc2-data)
  subnet_id      = aws_subnet.spokeVpc2-data[count.index].id
  route_table_id = aws_route_table.spokeVpc2-main-rt.id
}
