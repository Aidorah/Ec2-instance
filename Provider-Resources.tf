# Configure AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc-demo" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Demo"
}
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc-demo.id
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc-demo.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc-demo.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

# Create a route table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc-demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a security group
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.my_vpc-demo.id

  # Define inbound rules (adjust as needed)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere
  }

  # Define outbound rules (adjust as needed)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance in the public subnet
resource "aws_instance" "example" {
  ami                    = "ami-051f8a213df8bc089" # Enter your desired AMI ID
  instance_type          = "t2.micro"              # Enter your desired instance type
  subnet_id              = aws_subnet.public_subnet.id
  security_groups        = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
}