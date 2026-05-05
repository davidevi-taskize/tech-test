variable "subnet_id_b" {
  type = string
}

resource "aws_lb" "app" {
  name               = "tech-test"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    var.subnet_id,   # dmz 1 — eu-west-1a
    var.subnet_id_b  # dmz 2 — eu-west-1b
  ]
}

resource "aws_lb_target_group" "app" {
  name     = "tech-test"
  port     = 7999
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path    = "/helth"
    matcher = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.id
  port             = 7999
}
