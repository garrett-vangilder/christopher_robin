resource "aws_instance" "flask_server" {
  count                  = var.server_count
  ami                    = "ami-0557a15b87f6559cf" # Ubuntu v22.X.X
  instance_type          = "t2.micro"              # Free
  vpc_security_group_ids = [aws_security_group.sec_group_flask.id]

  key_name = data.aws_key_pair.deployer.key_name

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.aws_pem_key_path)
    host        = self.public_ip
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
    source      = "../../honey_pot/parser.py"
    destination = "/tmp/parser.py"
  }

  provisioner "file" {
    source      = "../../honey_pot/app.py"
    destination = "/tmp/app.py"
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
      "mv /tmp/wsgi.py /home/ubuntu/www/",
      "mv /tmp/parser.py /home/ubuntu/www/",
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
