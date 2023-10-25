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

variable "ecs_task_definitions" {
  description = "List of task definitions that ecs services use"
  type = list(object({
    family                  = string
    cpu                     = string
    memory                  = string
    network_mode            = string
    cpu_architecture        = string
    operating_system_family = string
    file_path               = string
  }))
  default                   = [ 
    {
      family = "selenium-terraform-hub"
      cpu = "4096"
      memory = "9216"
      network_mode = "awsvpc"
      cpu_architecture = "X86_64"
      operating_system_family = "LINUX"
      file_path = "task-definitions/selenium-hub.json"
    }, 
    {
      family = "selenium-terraform-node-chrome"
      cpu = "1024"
      memory = "2048"
      network_mode = "awsvpc"
      cpu_architecture = "X86_64"
      operating_system_family = "LINUX"
      file_path = "task-definitions/selenium-node-chrome.json"
    } 
  ]
}