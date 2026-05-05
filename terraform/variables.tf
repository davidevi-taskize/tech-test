variable "region" {
  default = "eu-west-1"
}

variable "vpc_id" {
  default = "vpc-0bb21ca8242319454"
}

variable "subnet_id" {
  default = "subnet-04ca6b89f261744b2" # Dev DMZ subnet in eu-west-1a
}

variable "ami_id" {
  default = "ami-0ca074890f176de41" # Amazon Linux 2023 (May 2026, eu-west-1)
}
