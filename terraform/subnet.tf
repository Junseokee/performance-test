data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Public VPC의 Public 서브넷
resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.public_vpc.id
  cidr_block              = slice(["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"], count.index, count.index + 1)[0]
  availability_zone       = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  map_public_ip_on_launch = true # Public 서브넷에서 EC2 인스턴스가 자동으로 퍼블릭 IP를 받도록 설정
  tags = {
    Name = "dps-test-${count.index}"
  }
}

resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.public_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
  }
}

resource "aws_route_table_association" "eks_route_table_association1" {
  count          = length(aws_subnet.public_subnet.*.id)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.eks_route_table.id
}