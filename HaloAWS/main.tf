terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.17"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "halo_terraform_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "halo-terraform"
  }
}

# Create public subnets
resource "aws_subnet" "halo_terraform_public_subnet_1" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.0/28"
  availability_zone = var.aws_az1

  depends_on = [ aws_vpc.halo_terraform_vpc ]

  tags = {
    Name = "halo-terraform-subnet-public1-ca-central-1a"
  }
}

resource "aws_subnet" "halo_terraform_public_subnet_2" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.16/28"
  availability_zone = var.aws_az2

  depends_on = [ aws_vpc.halo_terraform_vpc ]

  tags = {
    Name = "halo-terraform-subnet-public2-ca-central-1b"
  }
}

# Create private subnets
resource "aws_subnet" "halo_terraform_private_subnet_1" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.32/27"
  availability_zone = var.aws_az1

  depends_on = [ aws_vpc.halo_terraform_vpc ]

  tags = {
    Name = "halo-terraform-subnet-private1-ca-central-1a"
  }
}

resource "aws_subnet" "halo_terraform_private_subnet_2" {
  vpc_id = aws_vpc.halo_terraform_vpc.id
  cidr_block = "10.0.0.64/27"
  availability_zone = var.aws_az2

  depends_on = [ aws_vpc.halo_terraform_vpc ]

  tags = {
    Name = "halo-terraform-subnet-private1-ca-central-1b"
  }
}

# Create internet gateway and attach to VPC
resource "aws_internet_gateway" "halo-terraform-igw" {
  vpc_id = aws_vpc.halo_terraform_vpc.id

  depends_on = [ aws_vpc.halo_terraform_vpc ]

  tags = {
    Name = "halo-terraform-igw"
  }
}

# create public route table with route going to internet gateway
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.halo_terraform_vpc.id

  route {
    cidr_block = var.specify_all
    gateway_id = aws_internet_gateway.halo-terraform-igw.id
  }

  depends_on = [aws_vpc.halo_terraform_vpc ,aws_internet_gateway.halo-terraform-igw ]

  tags = {
    Name = "PublicRouteTable"
  }
}

# Create elastic public IP address and create and associate NAT gateway
resource "aws_eip" "haloPublicNatIP" {
  domain = "vpc"

  depends_on = [ aws_internet_gateway.halo-terraform-igw ]
}

resource "aws_nat_gateway" "haloNatGateway" {
  subnet_id = aws_subnet.halo_terraform_public_subnet_1.id
  allocation_id = aws_eip.haloPublicNatIP.id

  depends_on = [ 
    aws_vpc.halo_terraform_vpc, 
    aws_internet_gateway.halo-terraform-igw 
  ]

  tags = {
    Name = "halo-terraform-nat-gateway"
  }
}

# create private route tables with outbound going to nat gateway
resource "aws_route_table" "privateRouteTable1" {
  vpc_id = aws_vpc.halo_terraform_vpc.id

  route {
    cidr_block = var.specify_all
    gateway_id = aws_nat_gateway.haloNatGateway.id
  }

  depends_on = [ aws_vpc.halo_terraform_vpc, aws_subnet.halo_terraform_private_subnet_1, aws_nat_gateway.haloNatGateway ]

  tags = {
    Name = "halo-terraform-rtb-private1-ca-central-1a"
  }
}

resource "aws_route_table" "privateRouteTable2" {
  vpc_id = aws_vpc.halo_terraform_vpc.id

  route {
    cidr_block = var.specify_all
    gateway_id = aws_nat_gateway.haloNatGateway.id
  }

  depends_on = [ aws_vpc.halo_terraform_vpc, aws_subnet.halo_terraform_private_subnet_1, aws_nat_gateway.haloNatGateway ]

  tags = {
    Name = "halo-terraform-rtb-private1-ca-central-1b"
  }
}

# map public subnets to public route table
resource "aws_route_table_association" "public1Association" {
  subnet_id = aws_subnet.halo_terraform_public_subnet_1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "public2Association" {
  subnet_id = aws_subnet.halo_terraform_public_subnet_2.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

# map private subnets to private route tables
resource "aws_route_table_association" "private1Association" {
  subnet_id = aws_subnet.halo_terraform_private_subnet_1.id
  route_table_id = aws_route_table.privateRouteTable1.id
}

resource "aws_route_table_association" "private2Association" {
  subnet_id = aws_subnet.halo_terraform_private_subnet_2.id
  route_table_id = aws_route_table.privateRouteTable2.id
}

# Create halo security group (this is temporary and will be changed to allow a more narrow range of ip's and ports)
resource "aws_security_group" "halo_sg" {
  name = "haloTerraformSG"
  description = "Allow all port and all ips from inbound and outbound"
  vpc_id = aws_vpc.halo_terraform_vpc.id

  ingress {
    description = "Allow all in VPC"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.specify_all]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "Allow all from VPC"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.specify_all]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "haloTerraformSecurityGroup"
  }
}

#Load balancer setup
resource "aws_lb" "halo-elb" {
  name = "halo-terraform-elb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.halo_sg.id]
  subnets = [
    aws_subnet.halo_terraform_private_subnet_1.id, 
    aws_subnet.halo_terraform_private_subnet_2.id
  ]

  tags = {
    Application = "Halo"
  }
}

resource "aws_lb_target_group" "halo-targetGroup" {
  name = "terraform-selenium-nodes"
  port = 4444
  protocol = "HTTP"
  vpc_id = aws_vpc.halo_terraform_vpc.id

  depends_on = [ aws_lb.halo-elb ]

  tags = {
    Application = "Halo"
  }
}

resource "aws_lb_listener" "front_facing" {
  load_balancer_arn = aws_lb.halo-elb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.halo-targetGroup.arn
  }
}

# IAM Policy and Role for Halo
resource "aws_iam_role" "halo-ecs-role" {
  name = "halo-terraform-role"

  assume_role_policy = file("role-definitions/ecs-task-execution-role.json")
}

resource "aws_iam_role_policy" "halo-policy" {
  name = "Custom-Terraform-ECSTaskExecutionPolicy"
  role = aws_iam_role.halo-ecs-role.id

  policy = file("iam-policies/custom-ecs-task-execution-policy.json")

  depends_on = [ aws_iam_role.halo-ecs-role ]
}

# Task definitions
resource "aws_ecs_task_definition" "halo-hub" {
  for_each = { for definition in var.ecs_task_definitions: definition.family => definition }

  family = each.value.family
  cpu = each.value.cpu
  memory = each.value.memory
  network_mode = each.value.network_mode
  requires_compatibilities = [
    "FARGATE"
  ]

  execution_role_arn = aws_iam_role.halo-ecs-role.arn

  runtime_platform {
    cpu_architecture = each.value.cpu_architecture
    operating_system_family = each.value.operating_system_family
  }

  container_definitions = file(each.value.file_path)
}





