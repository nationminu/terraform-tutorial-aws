provider "aws" {
  region = "eu-west-1"
}

locals {
  user_data = <<EOF
#!/bin/bash
echo "Hello Terraform!"
EOF
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "ubuntu_focal" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners      = ["099720109477"]
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "my-key"
  public_key = "${file(pathexpand("~/.ssh/id_rsa.pub"))}"
  //public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3KhYWwE3F2OxiLplD1fqD0XpeEfEpZoJy8WEmi7RakAsDWPXBVrpwcXhIlaDm4VQCIGCUqxfEKR5jePz9yD7XM9okfXtHcwbkMBfhfO2oVEhs/e/P6EzuY8lHeUk5T/FqCCCGWCA8ktXQbOrzQ3qJion5ppQZqSV0fpuZv4cwf98jbMIFcMfbUNHGXFnsJWW0/7/vrQRa4Q4pDgEMIbxD2GNUg7iuvKGt4h7qNCvbw5Nk8SwmCR+Rw2yGG8BVQaZbSGhjCiU9Y0v08r0HaxCOLLt0aAOCaPXmsMGQAfiy5KEY+qUG/hzTho460o84RVkztDtpr30x4wvRyACwc9A5"
}

module "web_security_group" {
    source  = "terraform-aws-modules/security-group/aws"
    version = "~> 3.0"

    name        = "web_security_group"
    description = "Security group for http/https usage with EC2 instance"
    vpc_id      = data.aws_vpc.default.id

    ingress_cidr_blocks = ["0.0.0.0/0"]
    ingress_rules       = ["http-80-tcp", "https-443-tcp", "all-icmp"]
    egress_rules        = ["all-all"]

    tags = {
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong"
        Rules = "http"
    }  
}

module "ssh_security_group" {
    source  = "terraform-aws-modules/security-group/aws//modules/ssh"
    version = "~> 3.0" 

    name        = "ssh_security_group"
    description = "Security group for ssh usage with EC2 instance"
    vpc_id      = data.aws_vpc.default.id

    ingress_cidr_blocks = ["0.0.0.0/0"]  
    egress_rules        = ["all-all"]

    tags = {
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong"
        Rules = "SSH"
    }  
}

module "was_security_group" {
    source  = "terraform-aws-modules/security-group/aws//modules/http-8080"
    version = "~> 3.0"

    name        = "was_security_group"
    description = "Security group for was usage with EC2 instance"
    vpc_id      = data.aws_vpc.default.id

    ingress_cidr_blocks = ["0.0.0.0/0"]  
    egress_rules        = ["all-all"]

    tags = {
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong"
        Rules = "tomcat"
    }  
}

module "mysql_security_group" {
    source  = "terraform-aws-modules/security-group/aws//modules/mysql"
    version = "~> 3.0"

    name        = "mysql_security_group"
    description = "Security group for mysql usage with EC2 instance"
    vpc_id      = data.aws_vpc.default.id

    ingress_cidr_blocks = ["0.0.0.0/0"]  
    egress_rules        = ["all-all"]

    tags = {
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong"
        Rules = "mysql"
    }  
}

resource "aws_instance" "web" {
    count                   = 1
    ami                     = data.aws_ami.ubuntu_focal.id  
    instance_type           = "t2.micro"
    key_name                = module.key_pair.this_key_pair_key_name  
    vpc_security_group_ids  = [module.web_security_group.this_security_group_id,module.ssh_security_group.this_security_group_id]
    subnet_id               = tolist(data.aws_subnet_ids.all.ids)[0]
    associate_public_ip_address = true
 
    credit_specification {
        cpu_credits = "unlimited"
    }

    tags = {
        Name = "my-web ${count.index}"
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong"
        Group = "frontend"
    }  

    provisioner "local-exec" {
        command = "echo web-${count.index} ansible_host=${aws_instance.web[count.index].private_ip} ip=${aws_instance.web[count.index].public_ip}> > inventory.txt"
    }
} 

resource "aws_instance" "was" {
    count                   = 1
    ami                     = data.aws_ami.ubuntu_focal.id  
    instance_type           = "t2.micro"
    key_name                = module.key_pair.this_key_pair_key_name
    vpc_security_group_ids  = [module.was_security_group.this_security_group_id,module.ssh_security_group.this_security_group_id]
    subnet_id               = tolist(data.aws_subnet_ids.all.ids)[0]
    associate_public_ip_address = true
 
    credit_specification {
        cpu_credits = "unlimited"
    }

    tags = {
        Name = "my-was ${count.index}"
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong"
        Group = "backend"
    }  

    provisioner "local-exec" {
        command = "echo was-${count.index} ansible_host=${aws_instance.was[count.index].private_ip} ip=${aws_instance.was[count.index].public_ip} >> inventory.txt"
    }
}
  
resource "aws_instance" "db" {
    count                   = 1
    ami                     = data.aws_ami.ubuntu_focal.id  
    instance_type           = "t2.micro"
    key_name                = module.key_pair.this_key_pair_key_name  
    vpc_security_group_ids  = [module.mysql_security_group.this_security_group_id,module.ssh_security_group.this_security_group_id] 
    subnet_id               = tolist(data.aws_subnet_ids.all.ids)[0]  
    associate_public_ip_address = true
 
    credit_specification {
        cpu_credits = "unlimited"
    }

    tags = {
        Name = "my-db ${count.index}"
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong"
        Group = "database"
    }   

    provisioner "local-exec" {
        command = "echo db-${count.index} ansible_host=${aws_instance.db[count.index].public_ip} ip=${aws_instance.db[count.index].private_ip}  >> inventory.txt"
    }

    connection {
        user = "ubuntu"
        host = aws_instance.db[count.index].public_ip
        private_key = "${file(pathexpand("~/.ssh/id_rsa"))}"
        agent = "false"
        timeout = "5m"
    }
    
    provisioner "remote-exec" {
        inline = [
            "sudo yum -y update",
            "hostname"
        ]
    }
}