resource "aws_iam_openid_connect_provider" "github" {
  url = var.github_actions.oidc_provider_url

  client_id_list = ["sts.amazonaws.com"]

  lifecycle {
    prevent_destroy = true
  }
}
