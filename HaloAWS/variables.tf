variable "aws_region" {
  description = "Region to set aws provider to"
  type = string
  default = "ca-central-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type = string
  default = "10.0.0.0/24"
}

variable "aws_az1" {
    description = "Availability zone 1 for our vpc subnets"
  type = string
  default = "ca-central-1a"
}

variable "aws_az2" {
  description = "Availability zone 1 for our vpc subnets"
  type = string
  default = "ca-central-1b"
}

variable "specify_all" {
  description = "CIDR to specify all"
  type = string
  default = "0.0.0.0/0"
}