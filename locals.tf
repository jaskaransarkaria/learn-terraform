locals {
  stack_name    = "terraform-with-modules"
  owner         = "Jazz"
  image         = "nginx"
  region_az     = "eu-west-2a"
  vpc_cidr      = "10.0.0.0/16"
  subnet_cidr_1 = "10.0.1.0/24"
}
