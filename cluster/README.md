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
$ cd terraform-tutorial-aws/cluster/
```

# 클러스터링 설정
> web 그룹 , was 그룹, db 그룹의 ec2 인스턴스를 자동 생성하는 terrfarom 스크립트.

> main.tf <br>
> my-web, my-was, my-db -> 고유한 이름으로 변경<br>
> public_key -> 공개키가 있는 위치 지정<br>
> private_key -> 개인키가 있는 위치 지정 

```
$ vi main.tf
```

> init : 초기화 <br>
> plan : 실행전 테스트 <br>
> apply : 실행
```
$ terraform init
$ terraform plan
$ terraform apply
```

# terraform 진행 절차

> 1. 기본 VPC 정보 확인
> 2. 기본 subnet 정보 확인
> 3. ami ubuntu 20.04 정보 확인
> 4. key_pair 생성
> 5. security_group 생성 (ssh,http,mysql,was)
> 6. 위 내용으로 aws ec2 인스턴스 생성

# Single EC2 instance

> https://github.com/nationminu/terraform-tutorial-aws.git
