resource "aws_s3_bucket" "data_writer" {
  
    bucket = var.aws_bucket_name
    acl    = "private"
    
    tags = {
        Name        = var.aws_bucket_name
    }

    versioning {
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
    }
}