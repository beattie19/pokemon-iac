variable "service_prefix" {
  type = string
}
variable "account_id" {
  type = string
}

variable "my_region" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "isProd" {
  type    = bool
  default = false
}

variable "lambda_bucket_name" {
  type = string
}

variable "lambda_zip_filename" {
  type = string
}

variable "pokemon_queue" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "api_domain_name" {
  type = string
}

variable "dynamo_table_name" {
  type = string
}

