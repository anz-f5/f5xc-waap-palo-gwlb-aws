resource "volterra_cloud_credentials" "volterraCloudCredAWS" {
  name        = format("%s-cred", local.awsName)
  description = format("AWS credential will be used to create site %s", local.awsName)
  namespace   = "system"
  aws_secret_key {
    access_key = var.aws_access_key
    secret_key {
      clear_secret_info {
        url = "string:///${base64encode(var.aws_secret_key)}"
      }
    }
  }
}

resource "volterra_aws_vpc_site" "waapVpc-site" {
  name       = local.awsName
  namespace  = "system"
  aws_region = var.aws_region
  aws_cred {
    name      = volterra_cloud_credentials.volterraCloudCredAWS.name
    namespace = "system"
  }
  vpc {
    vpc_id = aws_vpc.waapVpc.id
  }
  disk_size     = var.site_disk_size
  instance_type = var.meshInstanceType

  ingress_egress_gw {
    aws_certified_hw = "aws-byol-multi-nic-voltmesh"
    az_nodes {
      aws_az_name            = local.awsAz1
      reserved_inside_subnet = false
      inside_subnet {
        existing_subnet_id = aws_subnet.waapVpc-internal[0].id
      }
      outside_subnet {
        existing_subnet_id = aws_subnet.waapVpc-external[0].id
      }
    }

    az_nodes {
      aws_az_name            = local.awsAz2
      reserved_inside_subnet = false
      inside_subnet {
        existing_subnet_id = aws_subnet.waapVpc-internal[1].id
      }
      outside_subnet {
        existing_subnet_id = aws_subnet.waapVpc-external[1].id
      }
    }

    az_nodes {
      aws_az_name            = local.awsAz3
      reserved_inside_subnet = false
      inside_subnet {
        existing_subnet_id = aws_subnet.waapVpc-internal[2].id
      }
      outside_subnet {
        existing_subnet_id = aws_subnet.waapVpc-external[2].id
      }
    }

    no_global_network        = true
    no_outside_static_routes = true
    no_network_policy        = true
    no_forward_proxy         = true
    forward_proxy_allow_all  = true
  }

  logs_streaming_disabled = true
  ssh_key                 = var.public_key
  lifecycle {
    ignore_changes = [labels]
  }
}

resource "null_resource" "wait_for_aws_mns" {
  triggers = {
    depends = volterra_aws_vpc_site.waapVpc-site.id
  }
}

resource "volterra_tf_params_action" "apply_aws_vpc" {
  depends_on       = [null_resource.wait_for_aws_mns]
  site_name        = local.awsName
  site_kind        = "aws_vpc_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = false
}


resource "aws_route_table" "waapVpc-intNlb-rt" {
  vpc_id = aws_vpc.waapVpc.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.transitGateway.id

  }

  tags = {
    Name = "${var.prefix}-waapVpc-intNlb-rt"
  }
}

resource "aws_route_table_association" "waapVpc-intNlb-association" {
  count          = length(aws_subnet.waapVpc-intNlb)
  subnet_id      = aws_subnet.waapVpc-intNlb[count.index].id
  route_table_id = aws_route_table.waapVpc-intNlb-rt.id
}

