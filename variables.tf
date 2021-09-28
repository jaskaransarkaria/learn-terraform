variable "owner" {
  type        = string
  description = "Who is creating these resources, used for tagging"
}

variable "image" {
  type        = string
  description = "The docker image to use for the server."
}

variable "stack_name" {
  type        = string
  description = "The name of the stack"
}

variable "region_az" {
  type        = string
  description = "The az to deploy to (this should be converted into a list as the project grows)"
}

variable "vpc_cidr" {
  type        = string
  description = "The cidr range for the vpc, usually a large block eg. /16"
}

variable "subnet_cidr_1" {
  type = string
  description = "The cidr range for a particular subnet (in future this should be an object containing all subnets)"
}

