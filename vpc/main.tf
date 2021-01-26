
provider "aws" {
  region = "eu-west-1"
}

locals {
  user_data = <<EOF
#!/bin/bash
echo "Hello Terraform!"
EOF
}
 
# VPC
resource "aws_vpc" "default" {
  cidr_block = "10.100.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "test-vpc"
  }
}

# SUBNET
resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.default.id
  cidr_block = "10.100.1.0/24" 

  tags = {
    Name = "Web Public Subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.default.id
  cidr_block = "10.100.2.0/24"

  tags = {
    Name = "Database Private Subnet"
  }
}

# GATEWAY
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "VPC IGW"
  }
}


# Route Table
resource "aws_route_table" "web-public-rt" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "web-public-rt" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.web-public-rt.id
}

# security group
resource "aws_security_group" "sgweb" {
  vpc_id = aws_vpc.default.id

  name = "vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "Web Server SG"
  }
}

resource "aws_security_group" "sgdb" {
  vpc_id = aws_vpc.default.id

  name = "sg_test_web"
  description = "Allow traffic from public subnet"
  
  ingress {
    from_port = 3306
    to_port = 3306 
    protocol = "tcp"
    cidr_blocks = ["10.100.1.0/24"]
  }
    
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.100.1.0/24"]
  }
 
  tags = {
    Name = "DB SG"
  }
}

resource "aws_instance" "web" { 
    ami                     = "ami-0aef57767f5404a3c"
    instance_type           = "t2.micro"
    key_name                = "key-mwsong" 
    vpc_security_group_ids  = [aws_security_group.sgweb.id] 
    subnet_id               = aws_subnet.public-subnet.id
    associate_public_ip_address = true
    source_dest_check = false
 
    credit_specification {
        cpu_credits = "unlimited"
    }

    tags = {
        Name = "webserver"
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong" 
    }    
}

resource "aws_instance" "db" { 
    ami                     = "ami-0aef57767f5404a3c"
    instance_type           = "t2.micro"
    key_name                = "key-mwsong" 
    vpc_security_group_ids  = [aws_security_group.sgdb.id] 
    subnet_id               = aws_subnet.private-subnet.id
    associate_public_ip_address = false
 
    credit_specification {
        cpu_credits = "unlimited"
    }

    tags = {
        Name = "database"
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong" 
    }    
}