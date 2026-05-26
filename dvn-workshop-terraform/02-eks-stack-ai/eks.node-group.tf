resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.eks.node_group.name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = data.terraform_remote_state.networking.outputs.private_subnet_ids
  instance_types  = var.eks.node_group.instance_types
  capacity_type   = var.eks.node_group.capacity_type
  ami_type        = var.eks.node_group.ami_type
  disk_size       = var.eks.node_group.disk_size

  scaling_config {
    desired_size = var.eks.node_group.desired_size
    min_size     = var.eks.node_group.min_size
    max_size     = var.eks.node_group.max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]
}
