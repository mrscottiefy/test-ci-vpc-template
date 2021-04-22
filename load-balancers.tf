resource "aws_lb" "jenkins-external-alb" {
  name                       = "alb-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}web-extalb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [aws_subnet.jenkins-public-subnet-az-a.id, aws_subnet.jenkins-public-subnet-az-b.id]
  enable_deletion_protection = false
  security_groups            = [aws_security_group.jenkins-external-alb-sg.id]
  tags = merge(
    local.default_tags,
    {
      Name       = "alb-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}web-extalb"
      Tier       = "web"
      Custom-Tag = "jenkins-external-alb"
    }
  )
}

resource "aws_lb_target_group" "jenkins-ext-alb-target-group" {
  name        = "jenkins-external-target-group"
  vpc_id      = local.vpc_id
  target_type = "instance"
  protocol    = "HTTP"
  port        = 80
}

resource "aws_lb_listener" "jenkins-ext-alb-listener" {
  load_balancer_arn = aws_lb.jenkins-external-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins-ext-alb-target-group.arn
  }
}

resource "aws_lb_target_group_attachment" "nginx-rp-a" {
  target_group_arn = aws_lb_target_group.jenkins-ext-alb-target-group.arn
  target_id        = aws_instance.nginx-reverse-proxy-a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "nginx-rp-b" {
  target_group_arn = aws_lb_target_group.jenkins-ext-alb-target-group.arn
  target_id        = aws_instance.nginx-reverse-proxy-b.id
  port             = 80
}

resource "aws_lb" "jenkins-internal-alb" {
  name                       = "alb-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-intalb"
  internal                   = true
  load_balancer_type         = "application"
  subnets                    = [aws_subnet.jenkins-private-subnet-az-a.id, aws_subnet.jenkins-private-subnet-az-b.id]
  enable_deletion_protection = false
  security_groups            = [aws_security_group.jenkins-internal-alb-sg.id]
  tags = merge(
    local.default_tags,
    {
      Name       = "alb-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-intalb"
      Tier       = "app"
      Custom-Tag = "jenkins-internal-alb"
    }
  )
}

resource "aws_lb_target_group" "jenkins-int-tg-master" {
  name        = "jenkins-int-tg-master"
  vpc_id      = local.vpc_id
  target_type = "ip"
  protocol    = "HTTP"
  port        = 8080
  health_check {
    path = "/login"
  }
}

resource "aws_lb_listener" "jenkins-int-alb-listener" {
  load_balancer_arn = aws_lb.jenkins-internal-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins-int-tg-master.arn
  }
}

