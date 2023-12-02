resource "aws_eip" "pub_a" {
  domain = "vpc"

  tags = {
    Name = "tf-eip-ap-northeast-2a"
  }
}

resource "aws_eip" "pub_c" {
  domain = "vpc"

  tags = {
    Name = "tf-eip-ap-northeast-2c"
  }
}

resource "aws_nat_gateway" "gw_a" {
  allocation_id = aws_eip.pub_a.id
  subnet_id     = aws_subnet.pub_a.id

  tags = {
    Name = "tf-nat-public1-ap-northeast-2a"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "gw_c" {
  allocation_id = aws_eip.pub_c.id
  subnet_id     = aws_subnet.pub_c.id

  tags = {
    Name = "tf-nat-public2-ap-northeast-2c"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "pri_a" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_a.id
  }

  tags = {
    Name = "tf-rtb-private1-ap-northeast-2a"
  }
}

resource "aws_route_table" "pri_c" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_c.id
  }

  tags = {
    Name = "tf-rtb-private2-ap-northeast-2c"
  }
}

resource "aws_route_table_association" "pri_a" {
  subnet_id      = aws_subnet.pri_a.id
  route_table_id = aws_route_table.pri_a.id
}

resource "aws_route_table_association" "pri_c" {
  subnet_id      = aws_subnet.pri_c.id
  route_table_id = aws_route_table.pri_c.id
}