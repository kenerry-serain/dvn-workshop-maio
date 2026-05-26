resource "aws_security_group" "cluster" {
  name        = "${var.eks.cluster_name}-cluster-sg"
  description = "Additional security group for the EKS cluster control plane."
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic."
  }

  tags = {
    Name = "${var.eks.cluster_name}-cluster-sg"
  }
}
