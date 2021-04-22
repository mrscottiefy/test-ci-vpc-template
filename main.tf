terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.32.0"
    }
  }
}

provider "aws" {
  profile = "dev-aws"
  region  = "ap-southeast-1"
}

locals {
  vpc_id                   = "vpc-0c7869fb70b78e2f9"
  vpc_default_sg           = "sg-0d6b0299f873840bc"
  ecs_execution_role       = "arn:aws:iam::896013561597:role/ecsTaskExecutionRole"
  ecs_task_role            = "arn:aws:iam::896013561597:role/ecsTaskExecutionRole"
  public_subnet_az_a_cidr  = "10.1.2.64/28"
  public_subnet_az_b_cidr  = "10.1.2.80/28"
  private_subnet_az_a_cidr = "10.1.2.0/27"
  private_subnet_az_b_cidr = "10.1.2.32/27"
  route_table_id           = "rtb-0c8d1c4ab39b5fff5"
  default_tags = {
    Agency-Code  = "hdb"
    Project-Code = "jenk01"
    Zone         = "dz"
    Environment  = "t01"
  }
}

resource "aws_cloudwatch_log_group" "jenkins-ecs-log-group" {
  name = "jenkins-ecs"
}

resource "aws_cloudwatch_log_group" "jenkins-ecs-slave-log-group" {
  name = "jenkins-ecs-slave"
}

resource "aws_ecs_cluster" "jenkins-ecs-cluster" {
  name               = "jenkins-ecs-master"
  capacity_providers = ["FARGATE"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    "name" = "jenkins-master"
  }
}

resource "aws_ecs_cluster" "jenkins-ecs-slave" {
  name               = "jenkins-ecs-slave"
  capacity_providers = ["FARGATE"]
  tags = {
    "name" = "jenkins-slave"
  }
}

resource "aws_ecs_task_definition" "jenkins-ecs-task" {
  family                   = "jenkins-ecs-task"
  container_definitions    = file("jenkins-main.json")
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  task_role_arn            = local.ecs_task_role
  execution_role_arn       = local.ecs_execution_role
  volume {
    name = "jenkins_home_efs"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.jenkins-efs.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.jenkins-efs-access-point.id
      }
    }
  }
}

resource "aws_ecs_service" "jenkins-ecs-service" {
  name            = "jenkins-master-service"
  cluster         = aws_ecs_cluster.jenkins-ecs-cluster.id
  task_definition = aws_ecs_task_definition.jenkins-ecs-task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins-int-tg-master.arn
    container_name   = "jenkins"
    container_port   = 8080
  }
  network_configuration {
    subnets          = [aws_subnet.jenkins-private-subnet-az-a.id, aws_subnet.jenkins-private-subnet-az-b.id]
    security_groups  = [aws_security_group.jenkins-ecs-sg.id]
    assign_public_ip = false
  }
  depends_on = [
    aws_lb_listener.jenkins-int-alb-listener
  ]
}
