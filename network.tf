
# Create a VPC
resource "aws_vpc" "terra-lexi" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terra-lexi"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.terra-lexi.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "example-public-subnet-lexi"
  }
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.terra-lexi.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "example-private-subnet-lexi"
  }
}

#Create a public subnet with a different zone
resource "aws_subnet" "public_subnet-b" {
  vpc_id     = aws_vpc.terra-lexi.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "example-public-subnet-lexi-b"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "igw-lexi" {
  vpc_id = aws_vpc.terra-lexi.id

  tags = {
    Name = "example-internet-gateway-lexi"
  }
}

# Create a route table
resource "aws_route_table" "rt-lexi" {
  vpc_id = aws_vpc.terra-lexi.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-lexi.id
  }

  tags = {
    Name = "example-route-table-lexi"
  }
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt-lexi.id
}

# Create a security group for the public subnet
resource "aws_security_group" "public_sg_lexi" {
  vpc_id = aws_vpc.terra-lexi.id

  # Define inbound and outbound rules for the security group as needed
  # For example, allow HTTP and HTTPS inbound traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-public-security-group-lexi"
  }
}

# Create a security group for the private subnet
resource "aws_security_group" "private_sg_lexi" {
  vpc_id = aws_vpc.terra-lexi.id

  # Define inbound and outbound rules for the security group as needed
  # For example, allow SSH inbound traffic from the public subnet
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg_lexi.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-private-security-group-lexi"
  }
}

