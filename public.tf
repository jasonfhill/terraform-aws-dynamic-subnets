locals {
  public_subnet_count = length(var.availability_zones)
}

resource "aws_subnet" "public" {
  count             = local.public_subnet_count
  vpc_id            = join("", data.aws_vpc.default.*.id)
  availability_zone = element(var.availability_zones, count.index)

  cidr_block = cidrsubnet(
    signum(length(var.cidr_block)) == 1 ? var.cidr_block : join("", data.aws_vpc.default.*.cidr_block),
    ceil(log(local.public_subnet_count * 2, 2)),
    local.public_subnet_count + count.index
  )

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    local.tags,
    {
      "Name" = format("%s-public-%s", var.alias, local.az_map[element(var.availability_zones, count.index)])
    }
  )

}

resource "aws_route_table" "public" {
  count  = 1
  vpc_id = join("", data.aws_vpc.default.*.id)

  tags = merge(
    local.tags,
    {
      "Name" = format("%s-public-%s", var.alias, local.az_map[element(var.availability_zones, count.index)])
    }
  )
}

resource "aws_route" "public" {
  count                  = 1
  route_table_id         = join("", aws_route_table.public.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id

  timeouts {
    create = var.aws_route_create_timeout
    delete = var.aws_route_delete_timeout
  }
}

resource "aws_route_table_association" "public" {
  count          = local.public_subnet_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}