terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "default"
}


#below code is to create an ECR repository for the final project
resource "aws_ecr_repository" "final_project" {
  name = "devops-bootcamp/final-project-kamariza"

  image_scanning_configuration {
    scan_on_push = true
}
    tags = {
        Name = "final-project-registry"
}
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}
output "ansible_server_private_ip" {
  value = aws_instance.ansible_server.private_ip
}
output "grafana_server_private_ip" {
  value = aws_instance.grafana_server.private_ip
}
output "ecr_repository_url" {
  value = aws_ecr_repository.final_project.repository_url
}