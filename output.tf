output "jenkins_alb_public_dns" {
  value = "http://${aws_lb.jenkins-external-alb.dns_name}"
}