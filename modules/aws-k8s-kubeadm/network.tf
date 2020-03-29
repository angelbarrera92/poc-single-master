data "aws_subnet" "public" {
  id = var.public_subnet_id
}

data "aws_subnet" "private" {
  id = var.private_subnet_id
}

data "aws_vpc" "vpc" {
  id = data.aws_subnet.public.vpc_id
}
