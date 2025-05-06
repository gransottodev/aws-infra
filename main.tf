terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.97.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}

module "network" {
  source = "./network"
}

module "tfstate" {
  source = "./config"
}