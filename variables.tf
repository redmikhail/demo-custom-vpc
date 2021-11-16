variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-2"
}

variable "bastion_ami" {
    description = "AMIs by region"
    default = {
        us-east-2 = "ami-01e36b7901e884a10" 
    }
}

variable "PROJECT_NAME" {
  type = string
  default = "illumio_demo"
}


variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}
