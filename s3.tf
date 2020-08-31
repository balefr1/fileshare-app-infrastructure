resource "aws_s3_bucket" "s3_bucket" {
    bucket = "${var.customer_name}-fileshare-app"
    acl = "private"
    versioning {
        enabled = false
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm     = "AES256"
            }
        }
    }
    tags = var.tags
}

