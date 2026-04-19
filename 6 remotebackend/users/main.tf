terraform {
  backend "s3" {
    bucket         = "first-terraform-s3-bucket-for-remote-backend"
    region         = "us-east-1"
    dynamodb_table = "first_remote_backend_locks"
    encrypt        = true
    key            = "dev/backend-state-users-dev"
  }
}


terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

}

resource "aws_iam_user" "my_iam_user" {
  name = "iam-user-created-during-practice"
}