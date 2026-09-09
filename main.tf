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

# #Public Subnets
# resource "aws_subnet" "public" {
#   count = length(var.public_subnet_cidrs)
#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.public_subnet_cidrs[count.index]
#   availability_zone = "us-east-1a"

#   tags = local.public_subnet_final_tags
# }

# resource "aws_subnet" "public" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.public_subnet_cidrs
#   availability_zone = "us-east-1a"

#   tags = local.public_subnet_final_tags
# }