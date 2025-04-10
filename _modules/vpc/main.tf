
locals {
  azs = length(data.aws_availability_zones.available.names)
  current_workspace = terraform.workspace
}
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = merge({
    Name = "fledxy_vpc"
  }, var.default_tags)
}

resource "aws_subnet" "public_subnet" {
  depends_on = [ aws_vpc.this ]
  count = local.azs
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name = "pbsub"
    public-aws_subnet = "true"
  }, var.default_tags)
}
resource "aws_subnet" "private_subnet" {
  depends_on = [ aws_vpc.this ]
  count = local.azs
  cidr_block = cidrsubnet(var.cidr_block, 8, local.azs + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name = "prvsub"
    public-aws_subnet = "false"
  }, var.default_tags)
}

resource "aws_internet_gateway" "igw" {
  depends_on = [ aws_vpc.this ]
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name = "IGW-fledxy"
  }, var.default_tags)
}

resource "aws_route" "public_route" {
    depends_on = [ 
        aws_internet_gateway.igw, 
        aws_vpc.this 
    ]
    route_table_id = aws_vpc.this.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_route-association" {
  depends_on = [ aws_vpc.this ]
  count = local.azs
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_vpc.this.main_route_table_id
}

### 

resource "aws_eip" "eip" {
    depends_on = [ aws_vpc.this ]
    count = local.azs
    tags = merge({
        Name = "eip_nat"
    }, var.default_tags)
}
resource "aws_nat_gateway" "private_nat" {
  depends_on = [ aws_vpc.this, aws_eip.eip ]
  count = local.azs
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
  tags = merge({

  }, var.default_tags)
}

resource "aws_nat_gateway" "ngw" {
  depends_on = [ aws_vpc.this ]
  count = local.azs
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  
}

resource "aws_route_table" "private_route_table" {
  depends_on = [ aws_vpc.this, aws_nat_gateway.private_nat ]
  count = local.azs
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.private_nat.*.id, count.index)
  }
  tags = merge({
    Name = "private-route-table-${count.index}"
  }, var.default_tags)
}
resource "aws_route_table_association" "private_route_table_association" {
  depends_on = [ aws_vpc.this ]
  count = local.azs
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}
### create the resources for database group
resource "aws_db_subnet_group" "db-subnet-group" {
  depends_on = [aws_vpc.this, aws_subnet.private_subnet]
  name       = "${var.vpc_name}-db-subnet-group"
  subnet_ids = data.aws_subnet_ids.private.ids
}