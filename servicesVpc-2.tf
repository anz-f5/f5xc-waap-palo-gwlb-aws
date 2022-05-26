module "vmseries-modules_gwlb" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/gwlb"
  version = "0.2.0"

  name             = "${var.prefix}-servicesVpc-gwlb"
  vpc_id           = aws_vpc.servicesVpc.id
  subnets          = { for az in aws_subnet.servicesVpc-data : az.availability_zone => { "id" : az.id } }
  target_instances = { for instance in aws_instance.fwInstance : instance.id => { "id" = instance.id } }

}

module "vmseries-modules_gwlb_ep2" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/gwlb_endpoint_set"
  version = "0.2.0"

  name              = "${var.prefix}-ep2-1"
  gwlb_service_name = module.vmseries-modules_gwlb.endpoint_service.service_name
  vpc_id            = aws_vpc.servicesVpc.id
  subnets           = { for az in aws_subnet.servicesVpc-ep2 : az.availability_zone => { "id" : az.id } }

}

