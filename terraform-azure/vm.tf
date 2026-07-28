resource "azurerm_public_ip" "backend" {
  name                = "ayalab-backend-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "backend" {
  name                = "ayalab-backend-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.backend.id
  }
}

resource "azurerm_linux_virtual_machine" "backend" {
  name                = "ayalab-backend"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s" # free-tier eligible
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.backend.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  disable_password_authentication = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable --now docker
    usermod -aG docker ${var.admin_username}
  EOF
  )

  tags = { Name = "ayalab-backend" }
}

# ── Copy JAR + Dockerfile and start the container ─────────────────────────────

resource "null_resource" "deploy" {
  depends_on = [
    azurerm_linux_virtual_machine.backend,
    azurerm_postgresql_flexible_server.main,
    azurerm_postgresql_flexible_server_database.main,
  ]

  triggers = {
    # Re-deploy whenever the JAR changes
    jar_hash = filemd5("${path.module}/../target/aya-lab-backend-${var.app_version}.jar")
  }

  connection {
    type        = "ssh"
    host        = azurerm_public_ip.backend.ip_address
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path)
  }

  # Wait for Docker to be ready (custom_data runs async)
  provisioner "remote-exec" {
    inline = [
      "until sudo docker info > /dev/null 2>&1; do echo 'waiting for docker...'; sleep 3; done",
      "mkdir -p /home/${var.admin_username}/app/target"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/../target/aya-lab-backend-${var.app_version}.jar"
    destination = "/home/${var.admin_username}/app/target/aya-lab-backend-${var.app_version}.jar"
  }

  provisioner "file" {
    source      = "${path.module}/../Dockerfile"
    destination = "/home/${var.admin_username}/app/Dockerfile"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.admin_username}/app",
      "sudo docker stop ayalab-backend 2>/dev/null || true",
      "sudo docker rm   ayalab-backend 2>/dev/null || true",
      "sudo docker build -t ayalab-backend:latest .",
      "sudo docker run -d --restart unless-stopped --name ayalab-backend -p 8080:8080 -e DB_URL=jdbc:postgresql://${azurerm_postgresql_flexible_server.main.fqdn}:5432/ayalab -e DB_USERNAME=ayalab -e DB_PASSWORD=${var.db_password} -e FRONTEND_ORIGIN=${var.frontend_origin} ayalab-backend:latest",
      "echo 'Deploy complete'"
    ]
  }
}
