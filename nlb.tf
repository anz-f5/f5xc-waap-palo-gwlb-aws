module "external-nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${var.prefix}-waapVpc-external-nlb"

  load_balancer_type = "network"

  vpc_id  = aws_vpc.waapVpc.id
  subnets = [for subnet in aws_subnet.waapVpc-extNlb : subnet.id]

  target_groups = [
    {
      name_prefix      = "${var.prefix}-"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
      targets = [
        {
          target_id = "10.1.0.252"
          port      = 80
        },
        {
          target_id = "10.1.1.225"
          port      = 80
        },
        {
          target_id = "10.1.2.228"
          port      = 80
        }
      ]
    },
    {
      name_prefix      = "${var.prefix}-"
      backend_protocol = "TCP"
      backend_port     = 443
      target_type      = "ip"
      targets = [
        {
          target_id = "10.1.0.252"
          port      = 443
        },
        {
          target_id = "10.1.1.225"
          port      = 443
        },
        {
          target_id = "10.1.2.228"
          port      = 443
        }
      ]
    },
    {
      name_prefix      = "${var.prefix}-"
      backend_protocol = "TCP"
      backend_port     = 6443
      target_type      = "ip"
      targets = [
        {
          target_id = "10.1.0.252"
          port      = 6443
        },
        {
          target_id = "10.1.1.225"
          port      = 6443
        },
        {
          target_id = "10.1.2.228"
          port      = 6443
        }
      ]
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
  subnets = [for subnet in aws_subnet.waapVpc-intNlb : subnet.id]

  target_groups = [
    {
      name_prefix      = "${var.prefix}-"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
      targets = [
        {
          target_id = "10.1.10.212"
          port      = 80
        },
        {
          target_id = "10.1.11.73"
          port      = 80
        },
        {
          target_id = "10.1.12.208"
          port      = 80
        }
      ]
    },

    {
      name_prefix      = "${var.prefix}-"
      backend_protocol = "TCP"
      backend_port     = 443
      target_type      = "ip"
      targets = [
        {
          target_id = "10.1.10.212"
          port      = 443
        },
        {
          target_id = "10.1.11.73"
          port      = 443
        },
        {
          target_id = "10.1.12.208"
          port      = 443
        }
      ]
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





