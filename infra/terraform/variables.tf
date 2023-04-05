variable "server_count" {
    type = number
}

variable "pub_ssh_key_path" {
    type = string
}


variable "priv_ssh_key_path" {
  type = string
}


variable "pub_rsa_ssh_key_path" {
    type = string
}


variable "priv_rsa_ssh_key_path" {
  type = string
}


##############################
# AWS
##############################
variable "aws_pem_key_path" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}


##############################
# GCP
##############################
variable "gcp_project_id" {
  type = string
}

variable "service_account_key_path" {
  type = string
}
