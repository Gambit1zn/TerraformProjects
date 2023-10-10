output "vpc_name" {
  description = "Name of the created vpc"
  value = aws_vpc.halo_terraform_vpc.tags.Name
}

output "nat_gateway_name" {
  description = "Name of the created NAT Gateway"
  value = aws_nat_gateway.haloNatGateway.tags.Name
}

output "nat_gateway_publicIp" {
  description = "Public IP of the created NAT Gateway"
  value = aws_nat_gateway.haloNatGateway.public_ip
}

output "nat_gateway_privateIp" {
  description = "Private IP of the created NAT Gateway"
  value = aws_nat_gateway.haloNatGateway.private_ip
}