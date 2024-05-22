resource "aws_vpc" "public_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "dps-test-vpc"
  }
}
output "public_vpc_id" {
  value = aws_vpc.public_vpc.id
}
