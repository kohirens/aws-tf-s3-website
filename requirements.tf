terraform {
  required_providers {
    sh = {
      source  = "kohirens/sh"
      version = "~> 0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}