#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "uno-crm" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "terraform-eks-uno-crm-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_subnet" "uno-crm" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.uno-crm.id

  tags = tomap({
    "Name"                                      = "terraform-eks-uno-crm-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "uno-crm" {
  vpc_id = aws_vpc.uno-crm.id

  tags = {
    Name = "terraform-eks-uno-crm"
  }
}

resource "aws_route_table" "uno-crm" {
  vpc_id = aws_vpc.uno-crm.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.uno-crm.id
  }
}

resource "aws_route_table_association" "uno-crm" {
  count = 2

  subnet_id      = aws_subnet.uno-crm.*.id[count.index]
  route_table_id = aws_route_table.uno-crm.id
}
