output "instance_public_ip" {
  value = aws_instance.app.public_ip
}

output "instance_private_ip" {
  value = aws_instance.app.private_ip
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}
