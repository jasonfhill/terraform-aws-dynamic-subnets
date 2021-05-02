data "aws_vpc" "default" {
  id    = var.vpc_id
}

locals {
  availability_zones_count = length(var.availability_zones)

  map_map = {
    short = "to_short"
    fixed = "to_fixed"
    full  = "identity"
  }

  az_map = module.utils.region_az_alt_code_maps[local.map_map[var.availability_zone_attribute_style]]

  tags                        = merge(var.tags,{

  })
}

module "utils" {
  source  = "github.com/jasonfhill/terraform-aws-utils"
}
