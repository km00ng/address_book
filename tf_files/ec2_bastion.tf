resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("./mykey.pub")
}

resource "aws_security_group" "web" {
  vpc_id      = aws_vpc.lab.id
  name_prefix = "web-sg-"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.pub_security_group_name
  }
}

resource "aws_instance" "web_pub" {
  ami = coalesce(var.image_id, data.aws_ami.amzlinux.id)
  # ami = "${var.image_id == "" ? data.aws_ami.amzlinux.id : var.image_id}"
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.mykey.key_name
  subnet_id                   = aws_subnet.pub_c.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  user_data                   = file("./userdata.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "tf-web-pub"
  }
}