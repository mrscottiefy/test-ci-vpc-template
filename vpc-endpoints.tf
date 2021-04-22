resource "aws_vpc_endpoint" "ecr-api-vpc-endpoint" {
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.ap-southeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.jenkins-external-alb-sg.id]
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.jenkins-private-subnet-az-a.id, aws_subnet.jenkins-private-subnet-az-b.id]
}

resource "aws_vpc_endpoint" "ecr-dkr-vpc-endpoint" {
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.ap-southeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.jenkins-external-alb-sg.id]
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.jenkins-private-subnet-az-a.id, aws_subnet.jenkins-private-subnet-az-b.id]
}

resource "aws_vpc_endpoint" "logs-vpc-endpoint" {
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.ap-southeast-1.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.jenkins-external-alb-sg.id]
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.jenkins-private-subnet-az-a.id, aws_subnet.jenkins-private-subnet-az-b.id]
}

resource "aws_vpc_endpoint" "ssm-vpc-endpoint" {
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.ap-southeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.jenkins-external-alb-sg.id]
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.jenkins-private-subnet-az-a.id, aws_subnet.jenkins-private-subnet-az-b.id]
}

resource "aws_vpc_endpoint" "s3-vpc-endpoint" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [local.route_table_id]
}
