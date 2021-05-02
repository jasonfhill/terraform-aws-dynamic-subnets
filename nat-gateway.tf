locals {
  nat_gateway_eip_count   = local.nat_gateways_count
  gateway_eip_allocations = aws_eip.default.*.id
  eips_allocations        = aws_eip.default.*.id
  nat_gateways_count      = length(var.availability_zones)
}

resource "aws_eip" "default" {
  count = local.nat_gateway_eip_count
  vpc   = true

  tags = merge(
    local.tags,
    {
      "Name" = format("%s-%s", var.namespace, local.az_map[element(var.availability_zones, count.index)])
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "default" {
  count         = local.nat_gateways_count
  allocation_id = element(local.gateway_eip_allocations, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    local.tags,
    {
      "Name" = format("%s-%s", var.namespace, local.az_map[element(var.availability_zones, count.index)])
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route" "default" {
  count                  = local.nat_gateways_count
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.default.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private]

  timeouts {
    create = var.aws_route_create_timeout
    delete = var.aws_route_delete_timeout
  }
}
