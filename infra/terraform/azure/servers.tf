resource "azurerm_linux_virtual_machine" "flask_server" {
  count = var.server_count

  name                      = "flask-server-${count.index}"
  location                  = "eastus"
  resource_group_name       = azurerm_resource_group.rg.name
  size                      = "Standard_B1s"
  admin_username            = "ubuntu"
  disable_password_authentication = true
  network_interface_ids     = [azurerm_network_interface.nic[count.index].id]

  admin_ssh_key {
    username   = "ubuntu"
    public_key =file(var.pub_ssh_key_path)
  }

  os_disk {
    caching                 = "ReadWrite"
    storage_account_type    = "Standard_LRS"
  }
  source_image_reference {
    offer                 = "0001-com-ubuntu-server-focal"
    publisher             = "Canonical"
    sku                   = "20_04-lts-gen2"
    version                 = "latest"
  }

  tags = {
    Name = "flask-server"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "null_resource" "ssh_connection" {
  count = var.server_count

  depends_on = [azurerm_linux_virtual_machine.flask_server]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.priv_ssh_key_path)
    host        = azurerm_linux_virtual_machine.flask_server[count.index].public_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'export DATA_INGEST_ENDPOINT=${var.data_ingest_endpoint}' >> ~/.bashrc"
    ]
  }  

  # install os level deps
  provisioner "remote-exec" {
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt update -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get update -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt install nginx -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt install python3.10-venv -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt install python3-pip -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt install python3-dev -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt install build-essential -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt install libssl-dev -y ",
      "sudo DEBIAN_FRONTEND=noninteractive apt install python3-setuptools -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install gunicorn -y"
    ]
  }

  # open firewall
  provisioner "remote-exec" {
    inline = [
      "sudo ufw allow 80",
      "sudo ufw allow 'Nginx HTTP'"
    ]
  }

  provisioner "file" {
    source      = "../../honey_pot/wsgi.py"
    destination = "/tmp/wsgi.py"
  }

  provisioner "file" {
    source      = "../../honey_pot/app.py"
    destination = "/tmp/app.py"
  }

  provisioner "file" {
    source      = "../../honey_pot/parser.py"
    destination = "/tmp/parser.py"
  }  

  provisioner "file" {
    source      = "../../honey_pot/requirements.txt"
    destination = "/tmp/requirements.txt"
  }

  provisioner "file" {
    source      = "../conf/systemd/honey_pot.service"
    destination = "/tmp/honey_pot.service"
  }

  provisioner "file" {
    source      = "../conf/nginx/honey_pot"
    destination = "/tmp/honey_pot"
  }

  # move files to the correct location
  provisioner "remote-exec" {
    inline = [
      "mkdir /home/ubuntu/www",
      "mv /tmp/app.py /home/ubuntu/www/",
      "mv /tmp/parser.py /home/ubuntu/www/",
      "mv /tmp/wsgi.py /home/ubuntu/www/",
      "mv /tmp/requirements.txt /home/ubuntu/www/",
      "sudo mv /tmp/honey_pot.service /etc/systemd/system/",
      "sudo mv /tmp/honey_pot /etc/nginx/sites-available/",
      "sudo rm -rf /etc/nginx/sites-available/default",
      "sudo rm -rf /etc/nginx/sites-enabled/default",
    ]
  }

  # because gunicorn needs to run on port 80, we need to bind the permissions of our user
  provisioner "remote-exec" {
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install authbind -y",
      "sudo touch /etc/authbind/byport/80",
      "sudo chmod 500 /etc/authbind/byport/80",
      "sudo chown ubuntu /etc/authbind/byport/80",
    ]
  }

  # install additional deps
  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu/www",
      "pip install wheel",
      "pip install -r requirements.txt",
    ]
  }

  # create envfile
  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu/www",
      "touch env",
      "echo 'DATA_INGEST_ENDPOINT=${var.data_ingest_endpoint}' >> env",
    ]
  }  

  # startup systemd process
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start honey_pot",
      "sudo systemctl enable honey_pot",
    ]
  }

  # startup nginx
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/user www-data;/user ubuntu;/' /etc/nginx/nginx.conf",
      "sudo ln -s /etc/nginx/sites-available/honey_pot /etc/nginx/sites-enabled",
      "sudo nginx -t",
      "sudo systemctl restart nginx",
    ]
  }
}  