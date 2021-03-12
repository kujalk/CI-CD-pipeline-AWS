/*
Purpose - To create an EC2 instance with VPC (Public Subnet) with Security Group attached
Developer - K.Janarthanan
*/

#VPC creation
resource "aws_vpc" "main" {
  cidr_block       = var.VPC_CIDR
  instance_tenancy = "default"

  tags = {
    Name = var.VPC_Name
  }
}

#Creating a subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.Subnet_CIDR
  map_public_ip_on_launch = true

  tags = {
    Name = var.Subnet_Name
  }
}

#Create IWG
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.IGW_Name
  }
}

#Route Table creation
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = var.RouteTable_PublicName
  }
}

#Associate the Route table with Subnet
resource "aws_route_table_association" "public-route" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.main.id
}

#Security Group
resource "aws_security_group" "main" {
  name        = var.SecurityGroup_Name
  description = "To allow HTTP and SSH Traffic"
  vpc_id      = aws_vpc.main.id


  tags = {
    Name = var.SecurityGroup_Name
  }

  ingress {
    description = "HTTP Traffic Allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Traffic Allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outside"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#EC2 instance creation for Dev
resource "aws_instance" "Dev" {
  ami                    = var.AMI_ID
  instance_type          = var.EC2_Size
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data_base64       = base64encode(local.html_install)
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "Dev_WebServer"
    Env  = "Dev-CICD"
  }
}

#EC2 instance creation
resource "aws_instance" "Prod" {
  ami                    = var.AMI_ID
  instance_type          = var.EC2_Size
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data_base64       = base64encode(local.html_install)
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "Prod_WebServer"
    Env  = "Prod-CICD"
  }
}
