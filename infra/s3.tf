data "aws_iam_policy_document" "read-public-bucket-policy" {
  statement {
    principals {
        type = "AWS"
        identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.dest-bucket.arn}/*"]
    actions = ["S3:GetObject"]
    effect = "Allow"
  }
}

resource "random_string" "predefined-guid-suffix" {
  length = 15
  special = false
  upper = false # S3 bucket names cannot have uppercase
} 
resource "aws_s3_bucket" "dest-bucket" {
  bucket = "${var.project-name}-dest-bucket-${random_string.predefined-guid-suffix.result}"
  acl = "public-read"
  tags = local.common_aws_tags 
}
resource "aws_s3_bucket_policy" "grant-all-read" {
  bucket = aws_s3_bucket.dest-bucket.id
  policy = data.aws_iam_policy_document.read-public-bucket-policy.json
}