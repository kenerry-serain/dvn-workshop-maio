resource "aws_eks_cluster" "this" {
  name                      = var.eks.cluster_name
  version                   = var.eks.cluster_version
  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = var.eks.cluster_log_types

  vpc_config {
    subnet_ids              = data.terraform_remote_state.networking.outputs.private_subnet_ids
    endpoint_private_access = var.eks.endpoint_private_access
    endpoint_public_access  = var.eks.endpoint_public_access
    security_group_ids      = [aws_security_group.cluster.id]
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}
