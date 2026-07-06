terraform {
  backend "s3" {
    bucket = "flask-app-terraform-state-882282737373"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}