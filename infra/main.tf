provider "aws" {
  region = "eu-central-1"
}


resource "aws_instance" "example" {
  ami           = "ami-0a628e1e89aaedf80"
  instance_type = var.instance_type
  key_name = "mockproject"
  vpc_security_group_ids = [aws_security_group.https.id, aws_security_group.ssh.id]
  subnet_id = aws_subnet.main-a.id
  associate_public_ip_address = true
  tags = {
    Name = "Gatus Instance"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Subnet
resource "aws_subnet" "main-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_a
  availability_zone = var.availability_zone_a
  tags = {
    Name = "main-subnet"
  }
}

# Public Subnet

resource "aws_subnet" "main-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-subnet"
  }
}

# Security Group
resource "aws_security_group" "https" {
  vpc_id = aws_vpc.main.id
  name   = "Allow Glogal HTTP"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 22
    to_port     = 8080
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
    Name = "main-security-group"
    Source = "Global"
  }
}

resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssh-security-group"
    Source = "Global"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main-b.id
  route_table_id = aws_route_table.main.id
}
