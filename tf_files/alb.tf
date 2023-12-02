resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"

  subnets         = [aws_subnet.pub_a.id, aws_subnet.pub_c.id]
  security_groups = [aws_security_group.alb.id]

  tags = {
    Name = var.alb_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found\n"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "asg" {
  name_prefix          = var.target_group_name
  port                 = var.server_port
  protocol             = "HTTP"
  vpc_id               = aws_vpc.lab.id
  deregistration_delay = "30" # 기본값 300

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn # "http"리스너의 arn
  priority     = 100                      # 우선순위 1~50000

  condition {
    path_pattern {
      values = ["*"] # 모든 패턴
    }
  }

  action {
    type             = "forward" # lb 타켓그룹 "asg"의 arn으로 포워딩
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_security_group" "alb" {
  vpc_id      = aws_vpc.lab.id
  name_prefix = var.alb_security_group_name
  description = "Allow HTTP inbound traffic"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
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
    Name = var.alb_security_group_name
  }

  lifecycle {
    create_before_destroy = true
  }
}