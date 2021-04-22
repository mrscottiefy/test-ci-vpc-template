resource "aws_instance" "nginx-reverse-proxy-a" {
  ami             = "ami-0ba0ce0c11eb723a1"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.jenkins-public-subnet-az-a.id
  user_data       = templatefile("user-data.sh", { jenkins_internal_alb = aws_lb.jenkins-internal-alb.dns_name })
  security_groups = [aws_security_group.jenkins-reverse-proxy-sg.id]
  tags = {
    "Name" = "nginx-reverse-proxy-a"
  }
}

resource "aws_instance" "nginx-reverse-proxy-b" {
  ami             = "ami-0ba0ce0c11eb723a1"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.jenkins-public-subnet-az-b.id
  user_data       = templatefile("user-data.sh", { jenkins_internal_alb = aws_lb.jenkins-internal-alb.dns_name })
  security_groups = [aws_security_group.jenkins-reverse-proxy-sg.id]
  tags = {
    "Name" = "nginx-reverse-proxy-b"
  }
}
