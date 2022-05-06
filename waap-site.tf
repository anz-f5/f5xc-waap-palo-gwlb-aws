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

module "external-nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${var.prefix}-waapVpc-external-nlb"

  load_balancer_type = "network"

  vpc_id  = aws_vpc.waapVpc.id
  subnets = [for subnet in aws_subnet.waapVpc-external : subnet.id]

  target_groups = [
    {
      name_prefix      = var.prefix
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
    },
    {
      name_prefix      = var.prefix
      backend_protocol = "TCP"
      backend_port     = 443
      target_type      = "ip"
    },
    {
      name_prefix      = var.prefix
      backend_protocol = "TCP"
      backend_port     = 6443
      target_type      = "ip"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 1
    },
    {
      port               = 6443
      protocol           = "TCP"
      target_group_index = 2
    }
  ]
}

module "internal-nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${var.prefix}-waapVpc-internal-nlb"

  load_balancer_type = "network"
  internal           = true

  vpc_id  = aws_vpc.waapVpc.id
  subnets = [for subnet in aws_subnet.waapVpc-internal : subnet.id]

  target_groups = [
    {
      name_prefix      = var.prefix
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
    },
    {
      name_prefix      = var.prefix
      backend_protocol = "TCP"
      backend_port     = 443
      target_type      = "ip"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 1
    }
  ]
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
