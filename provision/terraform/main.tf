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
      "sudo dnf -y install ansible"
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