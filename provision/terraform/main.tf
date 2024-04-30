# Create and bootstrap web-server
resource "aws_instance" "web-server" {
  ami                         = "ami-0fe630eb857a6ec83"
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.web-server-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id
  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y update && sudo dnf -y upgrade",
      "sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm",
      "sudo dnf -y install ansible",
      "sudo dnf -y install git"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/rhel-9-webserver-key")
      host        = self.public_ip
    }
  }
  tags = {
    Name = "web-server"
  }
}

# Harden the webserver
resource "null_resource" "harden" {
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /opt/playbooks",
      "sudo git clone https://github.com/Walrussin/Infrastructure-setup.git /opt/playbooks",
      "sudo ansible-playbook /opt/playbooks/harden/infra-autoconfig-playbook.yml",
      "sudo reboot"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/rhel-9-webserver-key")
      host        = aws_instance.web-server.public_ip
    }
  }
  depends_on = [aws_instance.web-server]
}

# Wait for reboot
resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
  depends_on = [null_resource.harden]
}

# Deploy all resources needed for application
resource "null_resource" "deploy" {
  provisioner "remote-exec" {
    inline = [
      "sudo ansible-playbook /opt/playbooks/deploy/deploy-autoconfig-playbook.yml -e aws_access_key_id=var.aws_access_key_id -e aws_secret_access_key=var.aws_secret_access_key",
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/rhel-9-webserver-key")
      host        = aws_instance.web-server.public_ip
    }
  }
  depends_on = [time_sleep.wait_30_seconds]
}