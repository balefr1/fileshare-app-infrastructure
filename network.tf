resource "aws_vpc" "vpc_download_2020" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    tags = var.tags
}

//private subnets
resource "aws_subnet" "subnet-priv-A" {
    vpc_id = "${aws_vpc.vpc_download_2020.id}"
    cidr_block = var.subnet-priv-A
    availability_zone = format("%sa",var.region)
    tags = var.tags
}

resource "aws_subnet" "subnet-priv-B" {
    vpc_id = "${aws_vpc.vpc_download_2020.id}"
    cidr_block = var.subnet-priv-B
    availability_zone = "${var.region}b"
    tags = var.tags
}

resource "aws_subnet" "subnet-priv-C" {
    vpc_id = "${aws_vpc.vpc_download_2020.id}"
    cidr_block = var.subnet-priv-C
    availability_zone = "${var.region}c"
    tags = var.tags
}

//public subnets
resource "aws_subnet" "subnet-pub-A" {
    vpc_id = "${aws_vpc.vpc_download_2020.id}"
    cidr_block = var.subnet-pub-A
    availability_zone = "${var.region}a"
    tags = var.tags
}

resource "aws_subnet" "subnet-pub-B" {
    vpc_id = "${aws_vpc.vpc_download_2020.id}"
    cidr_block = var.subnet-pub-B
    availability_zone = "${var.region}b"
    tags = var.tags
}

resource "aws_subnet" "subnet-pub-C" {
    vpc_id = "${aws_vpc.vpc_download_2020.id}"
    cidr_block = var.subnet-pub-C
    availability_zone = "${var.region}c"
    tags = var.tags
}

//internet gateway for public subnets
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc_download_2020.id}"
  tags = var.tags
}

//static ip for bastion host
resource "aws_eip" "bastion_eip" {
  vpc = true
  tags = var.tags
}

//static ip for natgw
resource "aws_eip" "natgw_eip" {
  vpc = true
  tags = var.tags
}

#a NAT GW should be created in every public subnet(one for each AZ),
#each private subnet should use the NAT in the public subnet in the same AZ.
resource "aws_nat_gateway" "nat_gw" {
    subnet_id = "${aws_subnet.subnet-pub-A.id}"
    allocation_id = "${aws_eip.natgw_eip.id}"
    tags = var.tags
}

resource "aws_route_table" "private_rt" {
  vpc_id = "${aws_vpc.vpc_download_2020.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = var.tags
}

resource "aws_route_table_association" "private_rt_a_association" {
  subnet_id      = "${aws_subnet.subnet-priv-A.id}"
  route_table_id = "${aws_route_table.private_rt.id}"
}

resource "aws_route_table_association" "private_rt_b_association" {
  subnet_id      = "${aws_subnet.subnet-priv-B.id}"
  route_table_id = "${aws_route_table.private_rt.id}"
}

resource "aws_route_table_association" "private_rt_c_association" {
  subnet_id      = "${aws_subnet.subnet-priv-C.id}"
  route_table_id = "${aws_route_table.private_rt.id}"
}

#Public Network
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.vpc_download_2020.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = var.tags
}

resource "aws_route_table_association" "public_rt_a_association" {
  subnet_id      = "${aws_subnet.subnet-pub-A.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_route_table_association" "public_rt_b_association" {
  subnet_id      = "${aws_subnet.subnet-pub-B.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_route_table_association" "public_rt_c_association" {
  subnet_id      = "${aws_subnet.subnet-pub-C.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
