data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "userdata" {
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    jenkins_version = var.jenkins_version
    efs_endpoint    = "${aws_efs_file_system.jenkins.dns_name}"
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.selected.id
}

data "template_file" "slave_userdata" {
  template = file("${path.module}/templates/slave.sh.tpl")
}

