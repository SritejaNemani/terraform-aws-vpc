resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # VPC Association

  tags = local.igw_final_tags
}

#Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true                        # default is false - but this is a Public subnet so we need Public IP
  tags = merge(
        local.common_tags,
        var.public_subnet_tags,
        {
          Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
        }
    )
}

#Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  # map_public_ip_on_launch = true                        # default is false - but this is a Public subnet so we need Public IP
  tags = merge(
        local.common_tags,
        var.private_subnet_tags,
        {
          Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
        }
    )
}

#Database Subnets
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  # availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true                        # default is false - but this is a Public subnet so we need Public IP
  tags = merge(
        local.common_tags,
        var.database_subnet_tags,
        {
          Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
        }
    )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
        local.common_tags,
        var.public_route_table_tags,
        {
          Name = "${var.project}-${var.environment}-public"
        }
    )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
        local.common_tags,
        var.private_route_table_tags,
        {
          Name = "${var.project}-${var.environment}-public"
        }
    )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
        local.common_tags,
        var.database_route_table_tags,
        {
          Name = "${var.project}-${var.environment}-public"
        }
    )
}