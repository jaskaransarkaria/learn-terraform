
variable region_az {
  default =  "eu-west-2a"
}

variable vpc_cidr {
  default = "10.0.0.0/16"
}

variable subnet_cidr_1 {
  default = "10.0.1.0/24"

}

variable tags {
  default = {
    Owner = "jaskaran"
  }
}

# 1. Create vpc
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Owner = var.tags.Owner
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Owner = var.tags.Owner
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Owner = var.tags.Owner
  }
}

# 4. Create a Subnet 
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_1
  availability_zone       = var.region_az
  map_public_ip_on_launch = true

  tags = {
    Owner = var.tags.Owner
  }
}

# 5. Associate subnet with Route Table
resource "aws_main_route_table_association" "main_rtb_association" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.rtb.id
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # means any
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = var.tags.Owner
  }
}
