terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.97.0"
    }
  }

  backend "s3" {
    bucket = "my-tf-state-aws-bucket-dev"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}

module "network" {
  source = "./network"
}