terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

module "sqs" {
  source        = "./modules/sqs"
  pokemon_queue = var.pokemon_queue
}

module "domain" {
  source          = "./modules/domain"
  api_domain_name = var.api_domain_name
  domain_name     = var.domain_name
}

module "dynamo" {
  source     = "./modules/dynamo"
  table_name = var.dynamo_table_name
}
