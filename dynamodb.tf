resource "aws_dynamodb_table" "pokemon-data" {
  name           = "pokemon-data"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "PokemonId"

  attribute {
    name = "PokemonId"
    type = "N"
  }
}