
#below code is web server security group
resource "aws_security_group" "web_sg" {
   name        = "devops-web-sg"
   description = "Allow HTTP and SSH traffic"
   vpc_id      = aws_vpc.main.id

   ingress {
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]    
    }
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/24"]   
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "devops-public-sg"
    }
    }

#below code is private server security group
resource "aws_security_group" "private_sg" {
   name        = "devops-private-sg"
   description = "Allow only SSH traffic from VPC"
   vpc_id      = aws_vpc.main.id

   ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["10.0.0.0/24"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "devops-private-sg"
    }
  }

#below code is to create an EC2 instance in the public subnet
  resource "aws_instance" "web_server" {
    ami                    = "ami-0ecb62995f68bb549"  # ubuntu 24.04 in us-east-1
    instance_type          = var.instance_type
    subnet_id              = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    associate_public_ip_address = true
    private_ip = "10.0.0.5"

    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

    tags = {
      Name = "web-server"
    }
  }

#below code is to create an ansible server in the private subnet
  resource "aws_instance" "ansible_server" {
    ami                    = "ami-0ecb62995f68bb549"  # ubuntu 24.04 in us-east-1
    instance_type          = var.instance_type
    subnet_id              = aws_subnet.private.id
    vpc_security_group_ids = [aws_security_group.private_sg.id]
    associate_public_ip_address = false
    private_ip = "10.0.0.135"

    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    key_name = aws_key_pair.ansible.key_name

#below code is to install ansible on the ansible server using user data
    user_data_replace_on_change = true
    user_data = <<-EOF
                #!/bin/bash
                apt update && apt upgrade -y
                apt install pipx -y
                pipx install --include-deps ansible
                pipx ensurepath
                source ~/.bashrc

                # create ssh folder
                mkdir -p /home/ubuntu/.ssh
                chmod 700 /home/ubuntu/.ssh

                # add private key to ssh folder
                cat > /home/ubuntu/.ssh/ansible-key.pem << 'PRIVKEY'
                ${tls_private_key.ssh_key.private_key_pem}
                PRIVKEY

                chmod 400 /home/ubuntu/.ssh/ansible-key.pem
                chown ubuntu:ubuntu /home/ubuntu/.ssh -R
                EOF

    tags = {
      Name = "ansible-controller"
    }
  }

#below code is to create a grafana server in the private subnet
  resource "aws_instance" "grafana_server" {
    ami                    = "ami-0ecb62995f68bb549"  # ubuntu 24.04 in us-east-1
    instance_type          = var.instance_type
    subnet_id              = aws_subnet.private.id
    vpc_security_group_ids = [aws_security_group.private_sg.id]
    associate_public_ip_address = false
    private_ip = "10.0.0.136"

    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    key_name = aws_key_pair.ansible.key_name

    tags = {
      Name = "grafana-server"
    }
  }
