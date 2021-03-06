################################################################################
# ECR
################################################################################
resource "aws_ecr_repository" "repo" {
  name                 = "${var.project_name}-server"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
