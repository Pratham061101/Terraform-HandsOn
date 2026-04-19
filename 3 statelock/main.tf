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

variable "names" {
    default = ["user111", "user112", "user2", "user3", "user4"]
}

resource "aws_iam_user" "my_iam_users" {
    #count = length(var.names)
    #name = var.names[count.index]

    for_each = toset(var.names)
    name = each.value
}