data "aws_iam_policy_document" "role-assume-pol" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "s3-interact-role" {
  name = "s3-interact"
  assume_role_policy = data.aws_iam_policy_document.role-assume-pol.json
  tags = local.common_aws_tags
}

data "aws_iam_policy_document" "role-pol" {
  statement {
    sid = "bucketInteractionPolicy"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutObjectTagging",
      "s3:GetObjectVersion"
    ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.dest-bucket.id}/*"]

  }
}

resource "aws_iam_role_policy" "s3-interact-role-policy" {
  name = "allow_rw_to_project_bucket"
  role = aws_iam_role.s3-interact-role.name
  policy = data.aws_iam_policy_document.role-pol.json

}