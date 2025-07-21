provider "aws" {
  region = "ap-south-1"
}

####################
# VPC (use existing)
####################
data "aws_vpc" "main_vpc" {
  id = "vpc-0cf9552d0478613b6"
}

##############################
# Internet Gateway (reuse if exists)
##############################
data "aws_internet_gateway" "existing_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
}

####################
# Subnet (reuse if exists)
####################
data "aws_subnet" "existing_public_subnet" {
  filter {
    name   = "cidr-block"
    values = ["10.0.1.0/24"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
}

##########################
# Security Group (reuse if exists)
##########################
data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["fastapi-sg"]
  }

  vpc_id = data.aws_vpc.main_vpc.id
}

####################
# Route Table (create if needed)
####################
resource "aws_route_table" "public_rt" {
  vpc_id = data.aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing_igw.id
  }

  tags = {
    Name = "july21-public-rt"
  }
}

##########################
# Route Table Association
##########################
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = data.aws_subnet.existing_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

####################
# EC2 Instance
####################
resource "aws_instance" "fastapi_ec2" {
  ami                         = "ami-03f4878755434977f" # Ubuntu 22.04 for ap-south-1
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.existing_public_subnet.id
  vpc_security_group_ids      = [data.aws_security_group.existing_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "FastAPI-EC2-july21"
  }
}
