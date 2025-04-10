data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "vpc" {
  id = resource.aws_vpc.this.id
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    public-aws_subnet = "false"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    public-aws_subnet = "true"
  }
}