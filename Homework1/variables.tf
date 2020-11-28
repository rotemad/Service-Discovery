variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "dev"
}

data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}