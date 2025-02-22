data "aws_availability_zones" "available" {
 state = "available"
 }

# Fetching my_ip code
data "http" "my_public_ip" {
  url = "https://ifconfig.me/ip" # or use any other service that returns your public IP
}

# Define a local value for the public IP
locals {
  my_public_ip = "${data.http.my_public_ip.response_body}/32"
}

# Output the my_ip value
output "my_ip" {
  value = local.my_public_ip
}

#create Linux ami
data "aws_ami" "amazon_linux" {
  most_recent = "true"
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}