
provider "aws" {
  region = "eu-west-1"
}

locals {
  user_data = <<EOF
#!/bin/bash
echo "Hello Terraform!"
EOF
}

resource "aws_instance" "ec2" { 
    ami                     = "ami-0aef57767f5404a3c"
    instance_type           = "t2.micro"
    key_name                = "key-mwsong" 
    vpc_security_group_ids  = ["sg-ff04ffa7"] 
    subnet_id               = "subnet-473c2f0f"
    associate_public_ip_address = true
 
    credit_specification {
        cpu_credits = "unlimited"
    }

    tags = {
        Name = "my-ec2"
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong" 
    }   

    provisioner "local-exec" {
        command = "echo myec2 ansible_host=${aws_instance.ec2.public_ip} ip=${aws_instance.ec2.private_ip}  >> inventory.txt"
    }

    connection {
        user = "ubuntu"
        host = aws_instance.ec2.public_ip
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