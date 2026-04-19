terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
    
}

variable "iam_user_name_prefix" {
    type = string
    default = "iam-users-cdp"
}

resource "aws_iam_user" "my_iam_users" {
    count = 4
    name = "${var.iam_user_name_prefix}-${count.index}"
}