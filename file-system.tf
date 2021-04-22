resource "aws_efs_file_system" "jenkins-efs" {
  encrypted = true
  tags = merge(
    local.default_tags,
    {
      Name       = "sst-efs-${local.default_tags.Agency-Code}-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-efs"
      Tier       = "app"
      Custom-Tag = "jenkins-efs"
    }
  )
}

resource "aws_efs_access_point" "jenkins-efs-access-point" {
  file_system_id = aws_efs_file_system.jenkins-efs.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/jenkins_home"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }
}

resource "aws_efs_mount_target" "jenkins-efs-mount-a" {
  file_system_id  = aws_efs_file_system.jenkins-efs.id
  subnet_id       = aws_subnet.jenkins-private-subnet-az-a.id
  security_groups = [aws_security_group.jenkins-efs-sg.id]
}

resource "aws_efs_mount_target" "jenkins-efs-mount-b" {
  file_system_id  = aws_efs_file_system.jenkins-efs.id
  subnet_id       = aws_subnet.jenkins-private-subnet-az-b.id
  security_groups = [aws_security_group.jenkins-efs-sg.id]
}
