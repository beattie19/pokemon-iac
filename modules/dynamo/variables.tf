variable "table_name" {
  type = string
}

variable "billing_mode" {
  type = string
  default = "PROVISIONED"
}

variable "read_capacity" {
  type = number
  default = 5
}

variable "write_capacity" {
  type = number
  default = 5
}

variable "hash_key" {
  type = string
  default = "PokemonId"
}
