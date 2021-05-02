locals {
  private_subnet_count = length(var.availability_zones)
}

resource "aws_subnet" "private" {
  count             = local.private_subnet_count
  vpc_id            = join("", data.aws_vpc.default.*.id)
  availability_zone = element(var.availability_zones, count.index)

  cidr_block = cidrsubnet(
    signum(length(var.cidr_block)) == 1 ? var.cidr_block : join("", data.aws_vpc.default.*.cidr_block),
    ceil(log(local.private_subnet_count * 2, 2)),
    count.index
  )

  tags = merge(
    local.tags,
    {
      "Name" = format("%s-private-%s", var.alias, local.az_map[element(var.availability_zones, count.index)])
    }
  )

}

resource "aws_route_table" "private" {
  count  = local.private_subnet_count
  vpc_id = join("", data.aws_vpc.default.*.id)

  tags = merge(
    local.tags,
    {
      "Name" = format("%s-private-%s", var.alias, local.az_map[element(var.availability_zones, count.index)])
    }
  )
}

resource "aws_route_table_association" "private" {
  count          = local.private_subnet_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}