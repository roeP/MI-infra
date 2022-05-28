resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "Jenkins"
  }

  key_name = var.ssh_key
  user_data     = data.template_file.userdata.rendered
  vpc_security_group_ids = ["${aws_security_group.jenkins_sg.id}"]

  depends_on = [
    aws_efs_mount_target.jenkins-mt
  ]
}


resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow http inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description      = "http from outside"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["62.219.194.102/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_security_group_rule" "ssh" {
  description              = "Allow ssh traffic"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_sg.id
  cidr_blocks              = ["62.219.194.102/32"]
  from_port                = 22
  to_port                  = 22
  type                     = "ingress"
}