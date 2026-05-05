output "instance_public_ip" {
  value = aws_instance.app.public_ip
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}
