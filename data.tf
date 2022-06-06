data "aws_network_interfaces" "waapVpc-nodesIntNics" {

  dynamic "filter" {
    for_each = var.intNic-filterTags
    iterator = tag
    content {
      name   = "tag:${tag.key}"
      values = ["${tag.value}"]
    }
  }
}

data "aws_network_interfaces" "waapVpc-nodesExtNics" {

  dynamic "filter" {
    for_each = var.extNic-filterTags
    iterator = tag
    content {
      name   = "tag:${tag.key}"
      values = ["${tag.value}"]
    }
  }
}

data "aws_network_interface" "waapVpc-nodeExtNic" {
  for_each = data.aws_network_interfaces.waapVpc-nodesExtNics.ids
  id       = each.key
}

data "aws_network_interface" "waapVpc-nodeIntNic" {
  for_each = data.aws_network_interfaces.waapVpc-nodesIntNics.ids
  id       = each.key
}
