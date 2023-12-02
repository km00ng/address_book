output "public_addrs" {
  description = "Public IPs of the bastion servers"
  value       = aws_instance.web_pub.public_ip

  depends_on = [aws_instance.web_pub]
}

output "db_endpoint" {
  value = aws_db_instance.tf_sql.address

  depends_on = [aws_db_instance.tf_sql]
}

output "load_balancer_dns" { # lb 전까지 주석처리
  value = aws_lb.alb.dns_name
}