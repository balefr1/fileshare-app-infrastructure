resource "aws_ecr_repository" "download_2020_repo" {
  name = "${var.customer_name}/fileshare-app"
  tags = var.tags
}

