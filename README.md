# TERRAFORM Tutorial for aws

# 수동으로 인스턴스 생성

## 1. Key Pair 생성
> 네트워크 및 보안 > 키페이

![aws](./img/aws_key_1.png)
> openSSH 와 함께 사용을 선택하고 "키 페어 생성"을 클릭하면 key-sample.pem 이 자동으로 다운로드. 이 파일로 모든 인스턴스를 접근.

![aws](./img/aws_key_2.png)


## 1. AWS bastion 인스턴스 생성
> EC2 > 인스턴스 > 인스턴스 시작

![aws](./img/aws_ec2_1.png)

## 2. 

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
locals {
    vm_prefix = "ec2" #CHANGEME
    user_data = <<EOF
    #!/bin/bash
    echo "Hello Terraform!"
    EOF 
}

resource "aws_instance" "ec2" { 
    count                   = 3
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
        Name = "${local.vm_prefix}-${count.index+1}"
        Terraform   = "true"
        Environment = "dev"
        Organization = "semyeong" 
    }   
 
    provisioner "local-exec" {
        command = "echo ${local.vm_prefix}-${count.index} ansible_host=${self.private_ip} ip=${self.public_ip} >> inventory.txt"
    }

    connection {
        user = "ubuntu"
        host = self.public_ip
        private_key = file(pathexpand("~/.ssh/id_rsa"))
        agent = "false"
        timeout = "5m"
    }
    
    provisioner "remote-exec" {
        inline = [
            "sudo apt -y update" 
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
