provider "aws" {
  region = var.aws_region
}

resource "random_pet" "name" {
  length = 2
  prefix = "TF-Modules_and_workspaces-"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    owner           = var.owner
    created-by      = var.created-by
    sleep-at-night  = var.sleep-at-night
    TTL             = var.TTL
  }
}


resource "aws_vpc" "default" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {Name = "${random_pet.name.id}-vpc"})
}

resource "aws_subnet" "default" {
  vpc_id     = aws_vpc.default.id
  cidr_block = var.cidr

  tags = merge(local.common_tags, {Name = "${random_pet.name.id}-subnet"})
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = merge(local.common_tags, {Name = "${random_pet.name.id}-internet_gateway"})
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = merge(local.common_tags, {Name = "${random_pet.name.id}-route_table"})
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
}