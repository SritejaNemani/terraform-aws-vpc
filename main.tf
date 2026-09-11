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

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_eip" "nat" {
  domain                    = "vpc"
  tags = merge(
        local.common_tags,
        var.eip_tags,
        {
          Name = "${var.project}-${var.environment}-nat"
        }
    )
}


resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id    #we are slecting one of two available az's   #NAT is placed in PUBLIC to communicate (eggress only) with 0.0.0.0 

  tags = merge(
        local.common_tags,
        var.nat_gateway_tags,
        {
          Name = "${var.project}-${var.environment}"
        }
    )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}


resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}