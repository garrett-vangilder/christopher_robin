module "core" {
  source = "./core"

  # core resources are deployed in aws
  aws_profile      = var.aws_profile
  aws_region       = var.aws_region
  aws_pem_key_path = var.aws_pem_key_path
}


module "aws" {
  source           = "./aws"
  server_count     = var.server_count
  aws_profile      = var.aws_profile
  aws_region       = var.aws_region
  aws_pem_key_path = var.aws_pem_key_path

  data_ingest_endpoint = module.core.data_ingest_url
}

# module "azure" {
#   source       = "./azure"
#   server_count = var.server_count
#   #  azure does not support id_ed255 keys, why? Not sure
#   priv_ssh_key_path = var.priv_rsa_ssh_key_path
#   pub_ssh_key_path  = var.pub_rsa_ssh_key_path
# }

# module "gcp" {
#   source            = "./gcp"
#   server_count      = var.server_count
#   priv_ssh_key_path = var.priv_ssh_key_path
#   pub_ssh_key_path  = var.pub_ssh_key_path

#   gcp_project_id           = var.gcp_project_id
#   service_account_key_path = var.service_account_key_path
# }
