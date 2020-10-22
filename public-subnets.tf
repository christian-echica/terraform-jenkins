# CREATING THE PUBLIC SUBNET
locals {
  az_names = data.aws_availability_zones.available_xtianzones.names
  //the code below * means there are multiple subnets
  pub_sub_ids = aws_subnet.public.*.id
}


resource "aws_subnet" "public" {
  # perform loop since you want to get all the availability zone and have all public subnet
  # so if got 6 zones it will create 6 public subnets
  count = length(local.az_names) // this line refers to the local variable above which is the counter
  vpc_id = aws_vpc.my_app.id
  # below is using the function cidrsubnet - This means to add 8 bits on the cidr 10.20.0.0/16(from variables.tf) which will
  # become 10.20.0.0/24 and the 1 will take the first cidr block which is 10.20.1.0/24. If you pass 2 then it will be
  # 10.20.2.0/24 And if 3 then it will be 10.20.3.0/24
  // cidr_block = cidrsubnet(var.vpc_cdir,8 , 1)
  cidr_block = cidrsubnet(var.vpc_cidr,8 , count.index) //just change from 1 to count.index
  # The line below is trying to access the data source in datasources.tf
  availability_zone = data.aws_availability_zones.available_xtianzones.names[count.index] //first entry on the list note: list type
  # THE LINE BELOW ENABLE SUBNET SETTING FOR AUTO ASSIGNING PUBLIC IP
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-${count.index + 1}" //This is to display like PublicSubnet-1 or PublicSubnet-2 and so on....
  }
}

# Now making it with IGW
resource "aws_internet_gateway" "igw-xtian" {
  vpc_id = aws_vpc.my_app.id
  tags = {
    Name = "JavaHomeIGW"
  }
}

# Create Route Table
resource "aws_route_table" "prt" {
  vpc_id = aws_vpc.my_app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-xtian.id
  }

  tags = {
    Name = "JavaHomePublicRT"
  }
}


# Associate the Route Table to the Subnet
resource "aws_route_table_association" "pub_sub_asociation" {
  count          = length(local.az_names)
  subnet_id = local.pub_sub_ids[count.index]
  route_table_id = aws_route_table.prt.id
}


