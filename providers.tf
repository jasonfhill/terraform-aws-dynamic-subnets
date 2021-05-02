provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws    = ">= 3.38"
  }
}