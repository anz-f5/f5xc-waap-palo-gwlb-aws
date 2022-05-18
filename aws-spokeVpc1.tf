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

resource "aws_subnet" "spokeVpc1-tsg" {
  vpc_id                  = aws_vpc.spokeVpc1.id
  count                   = length(var.spokeVpc1)
  cidr_block              = var.spokeVpc1[count.index].tsg_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.spokeVpc1[count.index].az

  tags = {
    Name = "${var.prefix}-spokeVpc1-tsg-${var.spokeVpc1[count.index].name}"
  }
}

module "spokeVpc1-ec2Instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                        = "${var.prefix}-spokeVpc1Ubuntu1"
  count                       = length(var.spokeVpc1)
  ami                         = "ami-0c4f7023847b90238"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ssh-keypair.key_name
  monitoring                  = false
  vpc_security_group_ids      = [aws_security_group.spokeVpc1-sg.id]
  subnet_id                   = aws_subnet.spokeVpc1-data[count.index].id
  associate_public_ip_address = "true"
}

resource "aws_route_table" "spokeVpc1-main-rt" {
  vpc_id = aws_vpc.spokeVpc1.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id
  }

  route {
    cidr_block = var.adminIp
    gateway_id = aws_internet_gateway.spokeVpc1-igw.id
  }

  route {
    cidr_block = "54.165.17.230/32"
    gateway_id = aws_internet_gateway.spokeVpc1-igw.id
  }

  tags = {
    Name = "${var.prefix}-spokeVpc1-main-rt"
  }
}

resource "aws_route_table_association" "spokeVpc1-main-association" {
  count          = length(aws_subnet.spokeVpc1-data)
  subnet_id      = aws_subnet.spokeVpc1-data[count.index].id
  route_table_id = aws_route_table.spokeVpc1-main-rt.id
}

resource "aws_internet_gateway" "spokeVpc1-igw" {
  vpc_id = aws_vpc.spokeVpc1.id

  tags = {
    Name = "${var.prefix}-spokeVpc1-igw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spokeVpc1TsgAttach" {
  subnet_ids                                      = [for subnet in aws_subnet.spokeVpc1-tsg : subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.transitGateway.id
  vpc_id                                          = aws_vpc.spokeVpc1.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"
  appliance_mode_support                          = "enable"

  tags = {
    "Name" = "${var.prefix}-spokeVpc1TsgAttach"
  }
}




