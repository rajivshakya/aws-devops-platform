resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {

    Name = "${var.project_name}-${var.environment}-vpc"

  }

}

data "aws_availability_zones" "available" {}
#tfsec:ignore:aws-ec2-no-public-ip-subnet
# Reason: Public subnet required for ALB
resource "aws_subnet" "public_subnet_1" {

  vpc_id = aws_vpc.main.id

  cidr_block = var.public_subnet_1_cidr

  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true

  tags = {

    Name = "${var.project_name}-${var.environment}-public-subnet-1"

  }

}

resource "aws_subnet" "public_subnet_2" {

  vpc_id = aws_vpc.main.id

  cidr_block = var.public_subnet_2_cidr

  availability_zone = data.aws_availability_zones.available.names[1]

  map_public_ip_on_launch = true

  tags = {

    Name = "${var.project_name}-${var.environment}-public-subnet-2"

  }

}

resource "aws_subnet" "private_subnet_1" {

  vpc_id = aws_vpc.main.id

  cidr_block = var.private_subnet_1_cidr

  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {

    Name = "${var.project_name}-${var.environment}-private-subnet-1"

  }

}

resource "aws_subnet" "private_subnet_2" {

  vpc_id = aws_vpc.main.id

  cidr_block = var.private_subnet_2_cidr

  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {

    Name = "${var.project_name}-${var.environment}-private-subnet-2"

  }

}

#################################################
# Internet Gatway provision                     #
#################################################
resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id

  tags = {

    Name = "${var.project_name}-${var.environment}-igw"

  }

}

#################################################
# EIP provision                     #
#################################################
resource "aws_eip" "nat_eip" {

  domain = "vpc"

  tags = {

    Name = "${var.project_name}-${var.environment}-nat-eip"

  }

}


#################################################
#   NAT Gw provision                     #
#################################################
resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat_eip.id

  subnet_id = aws_subnet.public_subnet_1.id

  tags = {

    Name = "${var.project_name}-${var.environment}-nat"

  }

  depends_on = [aws_internet_gateway.igw]

}

#################################################
# RT for Public Subnet provision & association                    #
#################################################
resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {

    Name = "${var.project_name}-${var.environment}-public-rt"

  }

}
resource "aws_route_table_association" "public_subnet_1_assoc" {

  subnet_id = aws_subnet.public_subnet_1.id

  route_table_id = aws_route_table.public_rt.id

}
resource "aws_route_table_association" "public_subnet_2_assoc" {

  subnet_id = aws_subnet.public_subnet_2.id

  route_table_id = aws_route_table.public_rt.id

}
#################################################
# RT for Private Subnet provision & association                    #
#################################################
resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.nat.id

  }

  tags = {

    Name = "${var.project_name}-${var.environment}-private-rt"

  }

}

resource "aws_route_table_association" "private_subnet_1_assoc" {

  subnet_id = aws_subnet.private_subnet_1.id

  route_table_id = aws_route_table.private_rt.id

}

resource "aws_route_table_association" "private_subnet_2_assoc" {

  subnet_id = aws_subnet.private_subnet_2.id

  route_table_id = aws_route_table.private_rt.id

}
