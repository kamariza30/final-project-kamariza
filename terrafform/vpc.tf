#below code is to create a VPC in AWS with a specified CIDR block
resource "aws_vpc" "main" {
   cidr_block = var.cidr_block

    tags = {
      Name = "devops-vpc"
    }
 }

#below code is to create a public subnet within the VPC
 resource "aws_subnet" "public" {
   vpc_id            = aws_vpc.main.id
   cidr_block        = "10.0.0.0/25"

   tags = {
     Name = "devops-public-subnet"
   }
 }

#below code is to create a private subnet within the VPC
resource "aws_subnet" "private" {
   vpc_id            = aws_vpc.main.id
   cidr_block        = "10.0.0.128/25"

   tags = {
     Name = "devops-private-subnet"
   }
 }

#below code is to create an internet gateway for the VPC
 resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.main.id

   tags = {
     Name = "devops-igw"
   }
 }


resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "devops-nat-eip"
  }
}

#below code is to create a NAT gateway in the public subnet
 resource "aws_nat_gateway" "nat" {
   allocation_id = aws_eip.nat.id
   subnet_id     = aws_subnet.public.id

   depends_on = [aws_internet_gateway.igw]

   tags = {
     Name = "devops-nat-gateway"
   }
 }

#below code is to create public route table for the VPC
 resource "aws_route_table" "public_rt" {
   vpc_id = aws_vpc.main.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.igw.id
   }
    tags = {
      Name = "devops-public-route"
    }
 }


#below code is to associate the public subnet with the public route table
 resource "aws_route_table_association" "public" {
   subnet_id      = aws_subnet.public.id
   route_table_id = aws_route_table.public_rt.id
 }


#below code is to create private route table for the VPC
 resource "aws_route_table" "private_rt" {
   vpc_id = aws_vpc.main.id

   route {
     cidr_block = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.nat.id
   }

   tags = {
     Name = "devops-private-route"
   }
 }  
#below code is to associate the private subnet with the private route table
 resource "aws_route_table_association" "private" {
   subnet_id      = aws_subnet.private.id
   route_table_id = aws_route_table.private_rt.id
 }