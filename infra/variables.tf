variable "bucket-name"{
    description = "The name of the bucket where uploaded objects will live in"
    default = ""
}
variable "tf-src"{
    description = "Source code of Terraform Stack"
    default = "https://github.com/eul721/itglue-assessment"
}

variable "project-name"{
    default = "itglue-assessment-new"
}

variable "vpc-id" {
    default = "vpc-0008652b23e4d7f10"
}