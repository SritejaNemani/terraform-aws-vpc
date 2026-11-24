resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1:0
  # peer_owner_id = var.peer_owner_id    - # will use this if peering between different AWS Account

  peer_vpc_id   = data.aws_vpc.default.id # Acceptor / Target VPC

  vpc_id        = aws_vpc.main.id # Requester VPC

  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-default"
    }
  )
}

resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1:0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block #check arguments in datasources to find exact like .id
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
}

resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1:0
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block #check arguments in datasources to find exact like .id
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
}
