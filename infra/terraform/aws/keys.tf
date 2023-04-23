data "aws_key_pair" "deployer" {
  key_name           = format("%s-tf",var.aws_profile)
  include_public_key = true
}
