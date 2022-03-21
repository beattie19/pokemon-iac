output "base_url" {
  value = aws_api_gateway_deployment.pokemon_deployment.invoke_url
}

output "populate_url" {
  value = "${aws_api_gateway_deployment.pokemon_deployment.invoke_url}/${aws_api_gateway_resource.populate-pokemon-resource.path_part}"
}

output "all_pokemon_url" {
  value = "${aws_api_gateway_deployment.pokemon_deployment.invoke_url}/${aws_api_gateway_resource.all-pokemon-resource.path_part}"
}