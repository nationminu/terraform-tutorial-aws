# TERRAFORM Tutorial

# AWS Credential
> 내 보안 자격 증명 (Identity and Access Management(IAM) > CLI, SDK 및 API 액세스를 위한 액세스 키
```
export AWS_ACCESS_KEY_ID=xxxx
export AWS_SECRET_ACCESS_KEY=xxx
```

# Terraform Download
> https://www.terraform.io/downloads.html

# Usage
To run this example you need to execute:
```
$ git clone https://github.com/nationminu/terraform-tutorial-aws.git
$ cd terraform-tutorial-aws
```

> main.tf <br>
> ec2 -> 고유한 이름으로 변경<br>
> private_key -> 개인키가 있는 위치 지정
```
resource "aws_instance" "ec2" { 
    ami                     = "ami-0aef57767f5404a3c"
    instance_type           = "t2.micro"
    key_name                = "key-example" 
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
```

> init : 초기화 <br>
> plan : 실행전 테스트 <br>
> apply : 실행
```
$ terraform init
$ terraform plan
$ terraform apply
```

# Multiple EC2 instance

> https://github.com/nationminu/terraform-tutorial-aws/tree/master/cluster/


# Referer
> https://registry.terraform.io/modules/terraform-aws-modules
> https://github.com/terraform-aws-modules
