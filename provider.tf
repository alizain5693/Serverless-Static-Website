terraform {
# Required providers
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.13.1"
    }
  }
}

provider "aws" {
  # Configuration options
    region = "us-east-1"
    profile = "default"
}

