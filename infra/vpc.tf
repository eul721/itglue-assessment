data "aws_vpc" "vpc" {
  id = var.vpc-id
}

data "aws_availability_zones" "available" { // Get all available availablility zone names 
  state = "available"
}

resource "aws_subnet" "private-zone1" {
  vpc_id = var.vpc-id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = cidrsubnet(data.aws_vpc.vpc.cidr_block,8,10)
  tags = local.common_aws_tags
}

resource "aws_subnet" "private-zone2" {
  vpc_id = var.vpc-id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = cidrsubnet(data.aws_vpc.vpc.cidr_block,8,12)
  tags = local.common_aws_tags
}

resource "aws_subnet" "public-zone1" {
  vpc_id = var.vpc-id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = cidrsubnet(data.aws_vpc.vpc.cidr_block,8,11)
  tags = local.common_aws_tags
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public-zone2" {
  vpc_id = var.vpc-id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = cidrsubnet(data.aws_vpc.vpc.cidr_block,8,13)
  tags = local.common_aws_tags
  map_public_ip_on_launch = true
}

# Nat Gateway

resource "aws_eip" "eip-natgateway-zone1" { }
resource "aws_eip" "eip-natgateway-zone2" { }
resource "aws_nat_gateway" "natgateway-zone1" {
  allocation_id = aws_eip.eip-natgateway-zone1.id
  subnet_id = aws_subnet.public-zone1.id
}
resource "aws_nat_gateway" "natgateway-zone2" {
  allocation_id = aws_eip.eip-natgateway-zone2.id
  subnet_id = aws_subnet.public-zone2.id
}

# Internet Gateway

resource "aws_internet_gateway" "public-zone-internet-gateway" {
  vpc_id = var.vpc-id
  tags = local.common_aws_tags

}

# Private Zone RTB

resource "aws_route_table" "private-zone-rtb-zone1" {
  vpc_id = var.vpc-id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway-zone1.id
  }
  tags = local.common_aws_tags

}

resource "aws_route_table" "private-zone-rtb-zone2" {
  vpc_id = var.vpc-id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway-zone2.id
  }
  tags = local.common_aws_tags

}


# Public Zone RTB

resource "aws_route_table" "public-zone-rtb" {
  vpc_id = var.vpc-id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public-zone-internet-gateway.id
  }
  tags = local.common_aws_tags

}

# RTB Associations

resource "aws_route_table_association" "private-zone-1-rtb" {
  subnet_id = aws_subnet.private-zone1.id
  route_table_id = aws_route_table.private-zone-rtb-zone1.id
}

resource "aws_route_table_association" "private-zone-2-rtb" {
  subnet_id = aws_subnet.private-zone2.id
  route_table_id = aws_route_table.private-zone-rtb-zone2.id
}

resource "aws_route_table_association" "public-zone-1-rtb" {
  subnet_id = aws_subnet.public-zone1.id
  route_table_id = aws_route_table.public-zone-rtb.id
}

resource "aws_route_table_association" "public-zone-2-rtb" {
  subnet_id = aws_subnet.public-zone2.id
  route_table_id = aws_route_table.public-zone-rtb.id
}

resource "aws_security_group" "public-sg" {
  description = "SG to use for public LBs/Instances"
  vpc_id = var.vpc-id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private-sg" {
  description = "Allow traffic only from public subnets"
  vpc_id = var.vpc-id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [aws_security_group.public-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}