module "aws" {
    source = "./aws"

    priv_ssh_key_path = var.priv_ssh_key_path
}