
provider "aws" {
  region = "eu-west-1"
}

locals {
    vm_prefix = "example" #CHANGEME
    vm_keyname = "key-sample" #CHANGEME
    user_data = <<EOF
    #!/bin/bash
    echo "Hello Terraform!"
    EOF 
}

resource "aws_instance" "ec2" { 
    count                   = 3
    ami                     = "ami-0aef57767f5404a3c"
    instance_type           = "t2.micro"
    key_name                = local.vm_keyname
    vpc_security_group_ids  = ["sg-ff04ffa7"] 
    subnet_id               = "subnet-473c2f0f"
    associate_public_ip_address = true
 
    credit_specification {
        cpu_credits = "unlimited"
    }

    tags = {
        Name = "${local.vm_prefix}-${count.index+1}"
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong" 
    }   
 
    provisioner "local-exec" {
        command = "echo ${local.vm_prefix}-${count.index+1} ansible_host=${self.private_ip} ip=${self.public_ip} >> inventory.txt"
    }

    connection {
        user = "ubuntu"
        host = self.public_ip
        private_key = file(pathexpand("./ssh/key.pem"))
        agent = "false"
        timeout = "5m"
    }
    
    provisioner "remote-exec" {
        inline = [
            "sudo apt -y update" 
        ]
    }
}