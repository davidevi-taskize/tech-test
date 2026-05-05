resource "tls_private_key" "deploy" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deploy" {
  key_name   = "tech-test-deploy"
  public_key = tls_private_key.deploy.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.deploy.private_key_pem
  filename        = "${path.module}/tech-test-deploy.pem"
  file_permission = "0600"
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  key_name                    = aws_key_pair.deploy.key_name
  associate_public_ip_address = true

  tags = {
    Name = "tech-test"
  }
}
