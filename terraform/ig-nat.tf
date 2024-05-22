resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.public_vpc.id
  tags = {
    Name = "dps-test-IGW"
  }
}

resource "aws_eip" "nat_eip" {
  count = 1
}