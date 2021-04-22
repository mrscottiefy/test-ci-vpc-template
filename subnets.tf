resource "aws_subnet" "jenkins-public-subnet-az-a" {
  vpc_id            = local.vpc_id
  availability_zone = "ap-southeast-1a"
  cidr_block        = local.public_subnet_az_a_cidr
  tags = merge(
    local.default_tags,
    {
      Name       = "sub-1a-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-jenkins"
      Tier       = "web"
      Custom-Tag = "Jenkins ECS Public AZ-B"
    }
  )
}

resource "aws_subnet" "jenkins-public-subnet-az-b" {
  vpc_id            = local.vpc_id
  availability_zone = "ap-southeast-1b"
  cidr_block        = local.public_subnet_az_b_cidr
  tags = merge(
    local.default_tags,
    {
      Name       = "sub-1b-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-jenkins"
      Tier       = "web"
      Custom-Tag = "Jenkins ECS Public AZ-B"
    }
  )
}

resource "aws_subnet" "jenkins-private-subnet-az-a" {
  vpc_id            = local.vpc_id
  availability_zone = "ap-southeast-1a"
  cidr_block        = local.private_subnet_az_a_cidr
  tags = merge(
    local.default_tags,
    {
      Name       = "sub-1a-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-jenkins"
      Tier       = "app"
      Custom-Tag = "Jenkins ECS Private AZ-A"
    }
  )
}

resource "aws_subnet" "jenkins-private-subnet-az-b" {
  vpc_id            = local.vpc_id
  availability_zone = "ap-southeast-1b"
  cidr_block        = local.private_subnet_az_b_cidr
  tags = merge(
    local.default_tags,
    {
      Name       = "sub-1b-${local.default_tags.Project-Code}-${local.default_tags.Environment}${local.default_tags.Zone}app-jenkins"
      Tier       = "app"
      Custom-Tag = "Jenkins ECS Private AZ-B"
    }
  )
}