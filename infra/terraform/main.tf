module "aws" {
  source = "./aws"

  aws_profile       = var.aws_profile
  aws_region        = var.aws_region
  aws_pem_key_path = var.aws_pem_key_path
}

module "gcp" {
  source = "./gcp"

  priv_ssh_key_path = var.priv_ssh_key_path
  pub_ssh_key_path = var.pub_ssh_key_path

  gcp_project_id           = var.gcp_project_id
  service_account_key_path = var.service_account_key_path
}
