# VPC:
resource "aws_vpc" "homework-vpc" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "homework-vpc"
  }
}

# Subnet
resource "aws_subnet" "homework-subnet" {
  vpc_id     = aws_vpc.homework-vpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "Homework-Subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "homework-gw" {
  vpc_id = aws_vpc.homework-vpc.id

  tags = {
    Name = "homework-gateway"
  }
}

# Routeing
resource "aws_route_table" "route_tables" {
  vpc_id = aws_vpc.homework-vpc.id

  tags = {
    Name = "homework-route"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.route_tables.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.homework-gw.id
}

resource "aws_route_table_association" "to-public-subnet-route" {
  subnet_id      = aws_subnet.homework-subnet.id
  route_table_id = aws_route_table.route_tables.id
}


# Create a public secutiry group with HTTP,SSH and ICMP allowed:
resource "aws_security_group" "public-sg" {
  name   = "homework-sg"
  vpc_id = aws_vpc.homework-vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }
  ingress {
    description = "Allow ICMP"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.10.0.0/16"]
  }  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "homework-sg"
  }
}