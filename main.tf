#1 vpc
resource "aws_vpc" "roger_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "roger_vpc"
  }
}
#2 igw
resource "aws_internet_gateway" "roger_igw" {
  vpc_id = aws_vpc.roger_vpc.id
  tags = {
    Name = "roger_igw"
  }
}
#3 public subnet
resource "aws_subnet" "roger_public_subnet" {
  count             = length(var.public_subnet_cidr) #length() returns the number of elements in a list
  vpc_id            = aws_vpc.roger_vpc.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index) #element() access items by index
  map_public_ip_on_launch = true
  tags = {
    Name = "roger_public_subnet_${count.index}"
  }
}

#4 public rtb
resource "aws_route_table" "roger_public_rt" {
  vpc_id = aws_vpc.roger_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.roger_igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.roger_public_rt.id
  subnet_id      = aws_subnet.roger_public_subnet[count.index].id
}

#private rtb

#5 EC2 security grp
resource "aws_security_group" "roger_web_sg" {
  name        = "roger_web_sg"
  description = "security group for web servers"
  vpc_id      = aws_vpc.roger_vpc.id

  ingress {
    description = "allow SSH from my computer"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip] ##fetching my_ip code
  }
  ingress {
    description = "allow all traffic thro HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "roger_web_sg"
  }
}


#5a create key-pair, stored in config folder here:using var.tf 
# resource "aws_key_pair" "roger_kp" {
#   key_name   = "roger_kp"
#   public_key =  file(var.public_key_path) 
# }
#5b create key-pair, stored in config folder here:using locals{} #refactor to key-pair outside of tf
# locals {
#   public_key_files = tolist(fileset(path.module, "*.pub")) #convert fileset() to list
# }
# resource "aws_key_pair" "roger_kp" {
#   key_name   = "roger_kp"
#   public_key = file(element(local.public_key_files, 0)) #element() access items by index
# }

#6 create EC2 roger_web
resource "aws_instance" "roger_web" {
  count                  = var.settings.web_app.count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.settings.web_app.instance_type
  subnet_id              = aws_subnet.roger_public_subnet[count.index].id
  # key_name               = aws_key_pair.roger_kp.key_name
  key_name                = "roger_linux_kp" # roger_linux_kp / roger_win_kp
  vpc_security_group_ids = [aws_security_group.roger_web_sg.id]
  tags = {
    Name = "roger_web_${count.index}"
  }
}
#7 Create a 1 GB EBS volume in the same AZ as the EC2 instance's subnet
resource "aws_ebs_volume" "roger" {
  count = var.settings.web_app.count #Match the number of instances
  availability_zone = aws_instance.roger_web[count.index].availability_zone
  size              = 1  #1GB
  tags = {
    Name = "roger_volume_${count.index}"
  }
}
#8 Attach the EBS volume to the EC2 instance
resource "aws_volume_attachment" "roger" {
  count       = var.settings.web_app.count #Match the number of instances
  instance_id = aws_instance.roger_web[count.index].id
  volume_id   = aws_ebs_volume.roger[count.index].id #Reference to the EBS volume
  device_name = "/dev/sdf"  # Device name to attach the volume
}
#9 create elastic IP for EC2
resource "aws_eip" "roger_web_eip" {
  count    = var.settings.web_app.count #Creates multiple EIPs based on the count
  instance = aws_instance.roger_web[count.index].id #Associates the EIP with the EC2 instance

  tags = {
    Name = "roger_web_eip_${count.index}" #Tags the EIP with a unique name 
  }
}

