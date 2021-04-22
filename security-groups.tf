resource "aws_security_group" "jenkins-external-alb-sg" {
  name        = "sgrp-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-extalb"
  description = "SG for jenkins external ALB"
  vpc_id      = local.vpc_id

  ingress {
    description = "HTTP from external ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from external ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags,
    {
      Name       = "sgrp-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}web-extalb"
      Tier       = "web"
      Custom-Tag = "jenkins-external-alb-sg"
    }
  )
}

resource "aws_security_group" "jenkins-reverse-proxy-sg" {
  name        = "sgrp-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}web-revproxy"
  description = "SG for jenkins RP"
  vpc_id      = local.vpc_id

  ingress {
    description     = "HTTP from ext ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins-external-alb-sg.id]
  }

  ingress {
    description     = "HTTPS from ext ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins-external-alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags,
    {
      Name       = "sgrp-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}web-revproxy"
      Tier       = "web"
      Custom-Tag = "jenkins-reverse-proxy-sg"
    }
  )
}

resource "aws_security_group" "jenkins-internal-alb-sg" {
  name        = "sgrp-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-intalb"
  description = "SG for jenkins internal ALB"
  vpc_id      = local.vpc_id

  ingress {
    description     = "HTTP from external ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins-reverse-proxy-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags,
    {
      Name       = "sgrp-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-intalb"
      Tier       = "app"
      Custom-Tag = "jenkins-internal-alb-sg"
    }
  )
}

resource "aws_security_group" "jenkins-efs-sg" {
  name        = "sgrp-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-efs"
  description = "SG for jenkins EFS"
  vpc_id      = local.vpc_id

  ingress {
    description     = "EFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins-ecs-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags,
    {
      Name       = "sgrp-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-efs"
      Tier       = "app"
      Custom-Tag = "jenkins-efs-sg"
    }
  )
}

resource "aws_security_group" "jenkins-ecs-sg" {
  name        = "sgrp-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-ecs"
  description = "SG for jenkins ECS"
  vpc_id      = local.vpc_id

  ingress {
    description     = "Jenkins port"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins-internal-alb-sg.id]
  }

  ingress {
    description     = "Jenkins slave port"
    from_port       = 50000
    to_port         = 50000
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins-internal-alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags,
    {
      Name       = "sgrp-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-ecs"
      Tier       = "app"
      Custom-Tag = "jenkins-ecs-sg"
    }
  )
}

resource "aws_security_group_rule" "cyclical-ecs-alb-rule" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "HTTP from ECS"
  security_group_id        = aws_security_group.jenkins-internal-alb-sg.id
  source_security_group_id = aws_security_group.jenkins-ecs-sg.id
}
