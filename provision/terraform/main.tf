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
      "sudo dnf -y install git",
      "sudo mkdir /opt/playbooks",
      "sudo git clone https://github.com/WaltonMcD/Infrastructure-setup.git /opt/playbooks",
      "sudo ansible-playbook /opt/playbooks/harden/infra-autoconfig-playbook.yml",
      "<<-EOT
      ssh ${local.ssh_args} ec2-user@${self.ipv4_address} '(sleep 2; sudo reboot)&'; sleep 3
      until ssh ${local.ssh_args} -o ConnectTimeout=2 root@${self.ipv4_address} true 2> /dev/null
      do
        echo "Waiting for node to reboot and become available..."
        sleep 3
      done
    EOT"

    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/rhel-9-webserver-key")
      host        = self.public_ip
    }
  }
  timeouts {
    create = "60m"
    update = "60m"  
    delete = "60m"  
  }
  tags = {
    Name = "web-server"
  }
}

resource "null_resource" "deploy" {
  provisioner "remote-exec" {
    inline = [
      "sudo ansible-playbook /opt/playbooks/deploy/deploy-autoconfig-playbook.yml",
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