resource "aws_api_gateway_rest_api" "populate-pokemon" {
  name = "populate-pokemon"
  description = "Entrypoint to creating SQS messages that will populate pokemon"
}

resource "aws_api_gateway_resource" "populate-pokemon-resource" {
  parent_id   = aws_api_gateway_rest_api.populate-pokemon.root_resource_id
  path_part   = "populate"
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon.id
}

resource "aws_api_gateway_method" "populate_pokemon_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.populate-pokemon-resource.id
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon.id
}

resource "aws_api_gateway_integration" "populate_pokemon_lambda_integration" {
  http_method = aws_api_gateway_method.populate_pokemon_get.http_method
  resource_id = aws_api_gateway_resource.populate-pokemon-resource.id
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon.id
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri = aws_lambda_function.create_pokemon_populate_messages.invoke_arn
}


resource "aws_api_gateway_deployment" "pokemon_deployment" {
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon.id
  stage_name = var.environment
  depends_on = [
    aws_api_gateway_integration.populate_pokemon_lambda_integration,
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "pokemon_stage" {
  deployment_id = aws_api_gateway_deployment.pokemon_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon.id
  stage_name    = "dev"
}

output "base_url" {
  value = aws_api_gateway_deployment.pokemon_deployment.invoke_url
}

output "populate_url" {
  value = "${aws_api_gateway_deployment.pokemon_deployment.invoke_url}/${aws_api_gateway_resource.populate-pokemon-resource.path_part}"
}