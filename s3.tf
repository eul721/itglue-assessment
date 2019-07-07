resource "random_string" "predefined-guid-suffix" {
    count = "${var.bucket-name == ""? 1 : 0}"
    length = 15
    special = false
    upper = false # S3 bucket names cannot have uppercase
} 
resource "aws_s3_bucket" "dest-bucket" {
    bucket = "${var.bucket-name == "" ? "dest-bucket-for-assessment-${random_string.predefined-guid-suffix[0].result}" : var.bucket-name}"
    acl = "public-read"

    tags = local.common_aws_tags 
}