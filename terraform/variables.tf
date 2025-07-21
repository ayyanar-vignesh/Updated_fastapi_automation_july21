# terraform/variables.tf

variable "region" {
  default = "ap-south-1"
}

variable "key_name" {
  description = "The name of your AWS EC2 key pair"
  type        = string
}

