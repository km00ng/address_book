resource "aws_ami_from_instance" "tf_ami" {
  name                    = "tf-ami-1.0"
  source_instance_id      = aws_instance.web_pub.id
  snapshot_without_reboot = true

  tags = {
    Name = "tf-ami"
  }
}

resource "aws_launch_template" "asg" {
  name_prefix            = "lt-asg-"
  image_id               = data.aws_ami.tf_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.asg.id]
  key_name               = "mykey"
  update_default_version = true

  depends_on = [aws_ami_from_instance.tf_ami, data.aws_ami.tf_ami]
}

resource "aws_security_group" "asg" {
  vpc_id      = aws_vpc.lab.id
  name_prefix = var.asg_security_group_name

  ingress {
    description     = "HTTP from VPC"
    from_port       = var.server_port
    to_port         = var.server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Allow SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.asg_security_group_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix = "asg-web-"
  launch_template {
    id      = aws_launch_template.asg.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [aws_subnet.pri_a.id, aws_subnet.pri_c.id]
  target_group_arns         = [aws_lb_target_group.asg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 30


  min_size = 2
  max_size = 4

  tag {
    key                 = "Name"
    value               = "tf-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      aws_launch_template.asg.latest_version
    ]
  }
}