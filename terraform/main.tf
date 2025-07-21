# VPC
data "aws_vpc" "main_vpc" {

  id = "vpc-0cf9552d0478613b6"
  
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.main_vpc.id
  tags   = { Name = "fastapi-igw" }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = data.aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags                    = { Name = "july21-public-subnet" }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = data.aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "fastapi_sg" {
  name        = "fastapi-sg"
  description = "Allow SSH and FastAPI access"
  vpc_id      = data.aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fastapi-security-group"
  }
}


# EC2 Instance
resource "aws_instance" "fastapi_ec2" {
  ami                         = "ami-03f4878755434977f" # Ubuntu 22.04 in ap-south-1
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.fastapi_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "FastAPI-EC2-july21"
  }

}