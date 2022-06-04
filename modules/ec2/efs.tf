resource "aws_efs_file_system" "jenkins" {
  creation_token = "jenkins"

  tags = {
    Name = "jenkins"
  }
}

resource "aws_efs_mount_target" "jenkins-mt" {
   file_system_id  = "${aws_efs_file_system.jenkins.id}"
   subnet_id = "subnet-0f49b807a33c04360" 
   security_groups = ["${aws_security_group.ingress-efs.id}"]
 }

resource "aws_security_group" "ingress-efs" {
  name = "ingress-efs-test-sg"

   // NFS
   ingress {
     security_groups = ["${aws_security_group.jenkins_sg.id}"]
     from_port = 2049
     to_port = 2049
     protocol = "tcp"
   }
}