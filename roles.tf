# POLICIES:
# POLICY 1 == Assume Role
data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ROLE
resource "aws_iam_role" "dashboard_server_role" {
  name               = "dashboard_server_role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

# POLICY 2 == PERMISSIONS TO ACCESS SUBNETS AND INSTANCES
data "aws_iam_policy_document" "list_subnets_and_instances_doc" {
  statement {
    sid = "1"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeSubnets"
    ]

    resources = [
      "*"
    ]
  }
}
resource "aws_iam_policy" "list_subnets_instances" {
  name        = "list-all-instances-policy"
  description = "List all instances and subnets for our dashboard"
  policy      = data.aws_iam_policy_document.list_subnets_and_instances_doc.json
}

# ATTACH ALL POLICIES TO THE ROLE
resource "aws_iam_role_policy_attachment" "list_instances_atch" {
  role       = aws_iam_role.dashboard_server_role.name
  policy_arn = aws_iam_policy.list_subnets_instances.arn
}
# CREATE AN INSTANCE PROFILE FROM THE ROLE
resource "aws_iam_instance_profile" "dashboard_server_profile" {
  name = "dashboard_server_profile"
  role = aws_iam_role.dashboard_server_role.name
}
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:pasc-ed/*:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "github-oidc"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}