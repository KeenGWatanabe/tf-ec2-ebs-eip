output "rger_igw" {
 value = aws_internet_gateway.rger_igw
}
output "vpc_id" {
  value = aws_vpc.rger_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.rger_public_subnet[*].id
}
output "public_subnet_azs" {
  value = aws_subnet.rger_public_subnet[*].availability_zone
    
}
output "public_subnet_ids_and_azs" {
  value = [
    for subnet in aws_subnet.rger_public_subnet : {
      id = subnet.id
      az = subnet.availability_zone
    }
  ]
}

output "public_subnet_count" {
  value = length(aws_subnet.rger_public_subnet)
}

output "public_subnet_cidr_blocks" {
  value = aws_subnet.rger_public_subnet[*].cidr_block
}

output "public_subnet_availability_zones" {
  value = aws_subnet.rger_public_subnet[*].availability_zone
}