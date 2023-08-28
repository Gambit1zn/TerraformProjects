terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "halo_terraform_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "halo-terraform"
  }
}

resource "aws_subnet" "halo_terraform_public_subnet_1" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.0/28"
  availability_zone = "ca-central-1a"

  depends_on = [ aws_vpc.halo_terraform_vpc ]

  tags = {
    Name = "halo-terraform-subnet-public1-ca-central-1a"
  }
}

resource "aws_subnet" "halo_terraform_public_subnet_2" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.16/28"
  availability_zone = "ca-central-1b"

  depends_on = [ aws_vpc.halo_terraform_vpc ]

    tags = {
    Name = "halo-terraform-subnet-public2-ca-central-1b"
  }
}

resource "aws_subnet" "halo_terraform_private_subnet_1" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.32/27"
  availability_zone = "ca-central-1a"

  depends_on = [ aws_vpc.halo_terraform_vpc ]

    tags = {
    Name = "halo-terraform-subnet-private1-ca-central-1a"
  }
}

resource "aws_subnet" "halo_terraform_private_subnet_2" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.64/27"
  availability_zone = "ca-central-1b"

  depends_on = [ aws_vpc.halo_terraform_vpc ]

    tags = {
    Name = "halo-terraform-subnet-private1-ca-central-1b"
  }
}

resource "aws_internet_gateway" "halo-terraform-igw" {
  vpc_id = aws_vpc.halo_terraform_vpc.id

  tags = {
    Name = "halo-terraform-igw"
  }

  depends_on = [ aws_vpc.halo_terraform_vpc ]
}

# resource "aws_internet_gateway_attachment" "halo-terraform-igw-attachment" {
#   internet_gateway_id = aws_internet_gateway.halo-terraform-igw.id
#   vpc_id = aws_vpc.halo_terraform_vpc.id

#   depends_on = [ aws_internet_gateway.halo-terraform-igw ]
# }

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.halo_terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.halo-terraform-igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}