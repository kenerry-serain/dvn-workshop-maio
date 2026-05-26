resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.vpc.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/flow-logs/${var.project.name}-${var.project.environment}"
  retention_in_days = var.vpc.flow_log_retention_days

  tags = {
    Name = "${var.project.name}-${var.project.environment}-vpc-flow-logs"
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.vpc.enable_flow_logs ? 1 : 0

  name = "${var.project.name}-${var.project.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project.name}-${var.project.environment}-vpc-flow-logs-role"
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.vpc.enable_flow_logs ? 1 : 0

  name = "${var.project.name}-${var.project.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
      }
    ]
  })
}

resource "aws_flow_log" "this" {
  count = var.vpc.enable_flow_logs ? 1 : 0

  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.vpc_flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn

  tags = {
    Name = "${var.project.name}-${var.project.environment}-vpc-flow-log"
  }

  depends_on = [
    aws_iam_role_policy.vpc_flow_logs,
    aws_cloudwatch_log_group.vpc_flow_logs,
  ]
}
