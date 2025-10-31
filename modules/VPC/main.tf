resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.environment}-igw" }
}

# public subnets
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[tonumber(each.key)]
  map_public_ip_on_launch = true
  tags = { Name = "${var.environment}-public-${each.key}" }
}

# private subnets
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[tonumber(each.key)]
  tags = { Name = "${var.environment}-private-${each.key}" }
}

# Elastic IPs for NAT gateways
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  vpc = true
  depends_on = [aws_internet_gateway.igw]
  tags = { Name = "${var.environment}-nat-eip-${each.key}" }
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  tags = { Name = "${var.environment}-nat-${each.key}" }
}

# route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.environment}-rt-public" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.environment}-rt-private" }
}

resource "aws_route" "private_default" {
  for_each = aws_nat_gateway.nat
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value.id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id = each.value.id
  route_table_id = aws_route_table.private.id
}
