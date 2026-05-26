resource "aws_ecr_repository" "this" {
  count = length(var.ecr.repository_names)

  name                 = "${var.project.name}/${var.project.environment}/${var.ecr.repository_names[count.index]}"
  image_tag_mutability = var.ecr.image_tag_mutability
  force_delete         = var.ecr.force_delete

  image_scanning_configuration {
    scan_on_push = var.ecr.scan_on_push
  }

  tags = {
    Name = "${var.project.name}/${var.project.environment}/${var.ecr.repository_names[count.index]}"
  }
}
