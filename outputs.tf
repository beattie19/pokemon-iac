output "populate_url" {
  value = "${aws_api_gateway_deployment.pokemon_deployment.invoke_url}/${var.environment}/${aws_api_gateway_resource.populate-pokemon-resource.path_part}"
}

output "all_pokemon_url" {
  value = "${aws_api_gateway_deployment.pokemon_deployment.invoke_url}/${var.environment}/${aws_api_gateway_resource.all-pokemon-resource.path_part}"
}

output "custom_populate_url" {
  value = "${var.api_domain_name}/${aws_api_gateway_resource.populate-pokemon-resource.path_part}"
}

output "custom_all_pokemon_url" {
  value = "${var.api_domain_name}/${aws_api_gateway_resource.all-pokemon-resource.path_part}"
}
