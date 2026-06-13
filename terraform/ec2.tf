# Latest Ubuntu 24.04 LTS AMI (ARM64 or x86 depending on instance type)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "ayalab-deployer"
  public_key = var.ssh_public_key
}

resource "aws_instance" "backend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"  # free tier
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable --now docker
    usermod -aG docker ubuntu
  EOF

  tags = { Name = "ayalab-backend" }
}

resource "aws_eip" "backend" {
  instance = aws_instance.backend.id
  domain   = "vpc"
  tags     = { Name = "ayalab-eip" }
}

# ── Copy JAR + Dockerfile and start the container ─────────────────────────────

resource "null_resource" "deploy" {
  depends_on = [aws_instance.backend, aws_db_instance.postgres, aws_eip.backend]

  triggers = {
    # Re-deploy whenever the JAR changes
    jar_hash = filemd5("${path.module}/../target/aya-lab-backend-${var.app_version}.jar")
  }

  connection {
    type        = "ssh"
    host        = aws_eip.backend.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
  }

  # Wait for Docker to be ready (user_data runs async)
  provisioner "remote-exec" {
    inline = [
      "until sudo docker info > /dev/null 2>&1; do echo 'waiting for docker...'; sleep 3; done",
      "mkdir -p /home/ubuntu/app/target"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/../target/aya-lab-backend-${var.app_version}.jar"
    destination = "/home/ubuntu/app/target/aya-lab-backend-${var.app_version}.jar"
  }

  provisioner "file" {
    source      = "${path.module}/../Dockerfile"
    destination = "/home/ubuntu/app/Dockerfile"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu/app",
      "sudo docker stop ayalab-backend 2>/dev/null || true",
      "sudo docker rm   ayalab-backend 2>/dev/null || true",
      "sudo docker build -t ayalab-backend:latest .",
      "sudo docker run -d --restart unless-stopped --name ayalab-backend -p 8080:8080 -e DB_URL=jdbc:postgresql://${aws_db_instance.postgres.address}:5432/ayalab -e DB_USERNAME=ayalab -e DB_PASSWORD=${var.db_password} -e FRONTEND_ORIGIN=${var.frontend_origin} ayalab-backend:latest",
      "echo 'Deploy complete'"
    ]
  }
}
