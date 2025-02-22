output "roger_igw" {
 value = aws_internet_gateway.roger_igw
}
output "vpc_id" {
  value = aws_vpc.roger_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.roger_public_subnet[*].id
}
output "public_subnet_azs" {
  value = aws_subnet.roger_public_subnet[*].availability_zone
    
}
output "public_subnet_ids_and_azs" {
  value = [
    for subnet in aws_subnet.roger_public_subnet : {
      id = subnet.id
      az = subnet.availability_zone
    }
  ]
}

output "public_subnet_count" {
  value = length(aws_subnet.roger_public_subnet)
}

output "public_subnet_cidr_blocks" {
  value = aws_subnet.roger_public_subnet[*].cidr_block
}

output "public_subnet_availability_zones" {
  value = aws_subnet.roger_public_subnet[*].availability_zone
}