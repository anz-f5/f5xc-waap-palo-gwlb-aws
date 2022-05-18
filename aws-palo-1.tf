resource "aws_vpc" "servicesVpc" {
  cidr_block           = var.paloVpcCidrBlock
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    "Name" = "${var.prefix}-servicesVpc"
  }
}

resource "aws_internet_gateway" "servicesVpc-igw" {
  vpc_id = aws_vpc.servicesVpc.id

  tags = {
    Name = "${var.prefix}-servicesVpc-igw"
  }
}

resource "aws_security_group" "servicesVpc-sg" {
  name   = "${var.prefix}-servicesVpc-sg"
  vpc_id = aws_vpc.servicesVpc.id

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

resource "aws_subnet" "servicesVpc-data" {
  vpc_id                  = aws_vpc.servicesVpc.id
  count                   = length(var.servicesVpc)
  cidr_block              = var.servicesVpc[count.index].data_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.servicesVpc[count.index].az

  tags = {
    Name = "${var.prefix}-servicesVpc-data-${var.servicesVpc[count.index].name}"
  }
}

resource "aws_subnet" "servicesVpc-mgmt" {
  vpc_id                  = aws_vpc.servicesVpc.id
  count                   = length(var.servicesVpc)
  cidr_block              = var.servicesVpc[count.index].mgmt_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.servicesVpc[count.index].az

  tags = {
    Name = "${var.prefix}-servicesVpc-mgmt-${var.servicesVpc[count.index].name}"
  }
}

resource "aws_subnet" "servicesVpc-tsg" {
  vpc_id                  = aws_vpc.servicesVpc.id
  count                   = length(var.servicesVpc)
  cidr_block              = var.servicesVpc[count.index].tsg_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.servicesVpc[count.index].az

  tags = {
    Name = "${var.prefix}-servicesVpc-tsg-${var.servicesVpc[count.index].name}"
  }
}

resource "aws_subnet" "servicesVpc-ep2" {
  vpc_id                  = aws_vpc.servicesVpc.id
  count                   = length(var.servicesVpc)
  cidr_block              = var.servicesVpc[count.index].ep2_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.servicesVpc[count.index].az

  tags = {
    Name = "${var.prefix}-servicesVpc-ep2-${var.servicesVpc[count.index].name}"
  }
}

resource "aws_route_table" "servicesVpc-mgmt-rt" {
  vpc_id = aws_vpc.servicesVpc.id

  tags = {
    Name = "${var.prefix}-servicesVpc-mgmt-rt"
  }
}

resource "aws_route" "servicesVpc-mgmt-route" {
  route_table_id         = aws_route_table.servicesVpc-mgmt-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.servicesVpc-igw.id
  depends_on             = [aws_route_table.servicesVpc-mgmt-rt]
}

resource "aws_route_table_association" "servicesVpc-mgmt-association" {
  count          = length(aws_subnet.servicesVpc-mgmt)
  subnet_id      = aws_subnet.servicesVpc-mgmt[count.index].id
  route_table_id = aws_route_table.servicesVpc-mgmt-rt.id
}

resource "aws_route_table" "servicesVpc-gwlbEp2-rt" {

  vpc_id = aws_vpc.servicesVpc.id

  route {
    cidr_block         = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id
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
    Name = "${var.prefix}-servicesVpc-gwlbEp2-rt"
  }
}

resource "aws_route_table_association" "servicesVpc-gwlbEp2-association" {
  count          = length(aws_subnet.servicesVpc-mgmt)
  subnet_id      = aws_subnet.servicesVpc-ep2[count.index].id
  route_table_id = aws_route_table.servicesVpc-gwlbEp2-rt.id
}

resource "aws_network_interface" "fw-mgmt-eni" {
  count             = length(var.servicesVpc)
  subnet_id         = aws_subnet.servicesVpc-mgmt[count.index].id
  security_groups   = [aws_security_group.servicesVpc-sg.id]
  source_dest_check = "false"

  tags = {
    Name = "${var.prefix}-fw-mgmt-eni-${var.servicesVpc[count.index].name}"
  }
}

resource "aws_network_interface" "fw-data-eni" {
  count             = length(var.servicesVpc)
  subnet_id         = aws_subnet.servicesVpc-data[count.index].id
  security_groups   = [aws_security_group.servicesVpc-sg.id]
  source_dest_check = "false"
  tags = {
    Name = "${var.prefix}-fw-data-eni-${var.servicesVpc[count.index].name}"
  }
}

resource "aws_eip" "fw-mgmt-eip" {
  count             = length(var.servicesVpc)
  vpc               = true
  network_interface = aws_network_interface.fw-mgmt-eni[count.index].id
  tags = {
    Name = "${var.prefix}-fw-mgmt-eip-${var.servicesVpc[count.index].name}"
  }
  depends_on = [aws_network_interface.fw-mgmt-eni, aws_instance.fwInstance]
}

resource "aws_iam_role" "fw-iam-role" {
  name               = "${var.prefix}-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "fw-iam-policy" {
  name        = "${var.prefix}-iam-policy"
  path        = "/"
  description = "IAM Policy for VM-Series Firewall"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Action": "s3:ListBucket",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "s3:GetObject",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:AttachNetworkInterface",
                "ec2:DetachNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  role       = aws_iam_role.fw-iam-role.name
  policy_arn = aws_iam_policy.fw-iam-policy.arn
}

resource "aws_iam_instance_profile" "iam-instance-profile" {
  name = "${var.prefix}-iam-profile"
  role = aws_iam_role.fw-iam-role.name
}

resource "aws_instance" "fwInstance" {
  count         = length(var.servicesVpc)
  ami           = var.firewall_ami_id
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.fw-data-eni[count.index].id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.fw-mgmt-eni[count.index].id
    device_index         = 1
  }
  iam_instance_profile = aws_iam_instance_profile.iam-instance-profile.id
  user_data            = "mgmt-interface-swap=enable\nplugin-op-commands=aws-gwlb-inspect:enable\n${var.user_data}"

  key_name = aws_key_pair.ssh-keypair.key_name
  tags = {
    Name = "${var.prefix}-fw-${var.servicesVpc[count.index].name}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "servicesTsgAttach" {
  subnet_ids                                      = [for subnet in aws_subnet.servicesVpc-tsg : subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.transitGateway.id
  vpc_id                                          = aws_vpc.servicesVpc.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"
  appliance_mode_support                          = "enable"


  tags = {
    "Name" = "${var.prefix}-servicesVpcTsgAttach"
  }
}



