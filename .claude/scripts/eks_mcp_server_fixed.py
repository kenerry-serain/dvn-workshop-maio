"""Start awslabs EKS MCP server with Kubernetes auth compatibility patch.

awslabs.eks-mcp-server 0.1.31 sets the Kubernetes Python client's API key
under "authorization". The Kubernetes client version resolved by uv expects
"BearerToken", otherwise it sends no Authorization header and EKS sees
requests as system:anonymous.
"""

from kubernetes import client


original_auth_settings = client.Configuration.auth_settings


def auth_settings_with_authorization_alias(self):
    auth = original_auth_settings(self)

    if "BearerToken" not in auth and "authorization" in self.api_key:
        auth["BearerToken"] = {
            "type": "api_key",
            "in": "header",
            "key": "authorization",
            "value": self.get_api_key_with_prefix("authorization"),
        }

    return auth


client.Configuration.auth_settings = auth_settings_with_authorization_alias


from awslabs.eks_mcp_server.server import main  # noqa: E402


if __name__ == "__main__":
    main()
