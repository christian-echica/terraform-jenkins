# CREATING PRIVATE SUBNET

resource "aws_subnet" "private" {
  // The slice function is make it only to 2 Private Subnet not 6 Subnets created to all AZ so we use slice() function
  count             = length(slice(local.az_names, 0, 2))
  vpc_id            = aws_vpc.my_app.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(local.az_names))
  availability_zone = local.az_names[count.index]
  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}

// THIS CODE CREATES A NAT INSTANCE NOTE: NOT NOT GATEWAY
resource "aws_instance" "nat" {
  ami                    = var.nat_amis[var.region] //have to target the current region in the variables.tf
  instance_type          = "t2.micro"
  subnet_id              = local.pub_sub_ids[0]
  source_dest_check      = false

  tags = {
    Name = "JavahomeNat"
  }
}

resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.my_app.id

  route {
    cidr_block  = "0.0.0.0/0"
     instance_id = aws_instance.nat.id
  }

  tags = {
    Name = "JavaHomePrivateRT"
  }
}

# ROUTE TABLE ASSOCIATE
resource "aws_route_table_association" "private_rt_association" {
  count          = length(slice(local.az_names, 0, 2))
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.privatert.id
}

resource "aws_security_group" "nat_sg" {
  name        = "nat_sg"
  description = "Allow traffic for private subnets"
  vpc_id      = aws_vpc.my_app.id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}