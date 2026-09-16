resource "aws_vpc_peering_connection" "default" {
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
}