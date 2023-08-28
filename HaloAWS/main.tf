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
}

resource "aws_subnet" "halo_terraform_public_subnet_1" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.0/28"
  availability_zone = "ca-central-1a"
}

resource "aws_subnet" "halo_terraform_public_subnet_2" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.16/28"
  availability_zone = "ca-central-1b"
}

resource "aws_subnet" "halo_terraform_private_subnet_1" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.32/27"
  availability_zone = "ca-central-1a"
}

resource "aws_subnet" "halo_terraform_private_subnet_2" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.64/27"
  availability_zone = "ca-central-1b"
}
