locals {
    common_aws_tags = {
        project = var.project-name
        tf-src = var.tf-src
    }  
    public_subnets = [
        aws_subnet.public-zone1,
        aws_subnet.public-zone2
    ]
    private_subnets = [
        aws_subnet.private-zone1,
        aws_subnet.private-zone2
    ]
}