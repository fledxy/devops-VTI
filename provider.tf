provider "aws" {
  region = "ap-southeast-1"
  access_key = "AKIAVPEYWBK6DAYC52YU"
  secret_key = "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"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
  }
}