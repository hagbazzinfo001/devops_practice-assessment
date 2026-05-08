# IAM Group for Kops Operations
resource "aws_iam_group" "kops" {
  name = "${var.project_name}-kops-group"
}

# Attach necessary policies to the group
resource "aws_iam_group_policy_attachment" "kops_ec2" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "kops_route53" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "kops_s3" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "kops_iam" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_group_policy_attachment" "kops_vpc" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_group_policy_attachment" "kops_cloudwatch" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM User for Kops
resource "aws_iam_user" "kops" {
  name = "${var.project_name}-kops-user"
}

resource "aws_iam_user_group_membership" "kops" {
  user = aws_iam_user.kops.name
  groups = [
    aws_iam_group.kops.name
  ]
}

# Access Keys for the user
resource "aws_iam_access_key" "kops" {
  user = aws_iam_user.kops.name
}
