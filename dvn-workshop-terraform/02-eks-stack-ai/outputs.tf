output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server."
  value       = aws_eks_cluster.this.endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the EKS cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "eks_cluster_security_group_id" {
  description = "The ID of the EKS cluster security group created by EKS."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "eks_cluster_version" {
  description = "The Kubernetes version of the EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "eks_node_group_arn" {
  description = "The ARN of the EKS node group."
  value       = aws_eks_node_group.this.arn
}

output "eks_node_group_status" {
  description = "The status of the EKS node group."
  value       = aws_eks_node_group.this.status
}

output "eks_cluster_iam_role_arn" {
  description = "The ARN of the IAM role used by the EKS cluster."
  value       = aws_iam_role.cluster.arn
}

output "eks_node_iam_role_arn" {
  description = "The ARN of the IAM role used by the EKS node group."
  value       = aws_iam_role.node.arn
}
