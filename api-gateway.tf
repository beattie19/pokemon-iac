resource "aws_api_gateway_rest_api" "populate-pokemon" {
  name        = "populate-pokemon"
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
  http_method             = aws_api_gateway_method.populate_pokemon_get.http_method
  resource_id             = aws_api_gateway_resource.populate-pokemon-resource.id
  rest_api_id             = aws_api_gateway_rest_api.populate-pokemon.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_pokemon_populate_messages.invoke_arn
}


resource "aws_api_gateway_deployment" "pokemon_deployment" {
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon.id
  stage_name  = var.environment
  depends_on = [
    aws_api_gateway_integration.populate_pokemon_lambda_integration,
    aws_api_gateway_integration.all_pokemon_lambda_integration,
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "pokemon_stage" {
  deployment_id = aws_api_gateway_deployment.pokemon_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon.id
  stage_name    = var.environment
}


#==============================================

// pretty much duplicated
resource "aws_api_gateway_resource" "all-pokemon-resource" {
  parent_id   = aws_api_gateway_rest_api.populate-pokemon.root_resource_id
  path_part   = "all-pokemon"
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon.id
}


// pretty much duplicated

resource "aws_api_gateway_method" "all_pokemon_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.all-pokemon-resource.id
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon.id
}
// pretty much duplicated

resource "aws_api_gateway_integration" "all_pokemon_lambda_integration" {
  http_method             = aws_api_gateway_method.all_pokemon_get.http_method
  resource_id             = aws_api_gateway_resource.all-pokemon-resource.id
  rest_api_id             = aws_api_gateway_rest_api.populate-pokemon.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_all_pokemon_from_db.invoke_arn
}

resource "aws_api_gateway_method" "all_pokemon_options" {
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon.id
  resource_id   = aws_api_gateway_resource.all-pokemon-resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon.id
  resource_id = aws_api_gateway_resource.all-pokemon-resource.id
  http_method = aws_api_gateway_method.all_pokemon_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [aws_api_gateway_method.all_pokemon_options]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon.id
  resource_id = aws_api_gateway_resource.all-pokemon-resource.id
  http_method = aws_api_gateway_method.all_pokemon_options.http_method
  type        = "MOCK"
  depends_on  = [aws_api_gateway_method.all_pokemon_options]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon.id
  resource_id = aws_api_gateway_resource.all-pokemon-resource.id
  http_method = aws_api_gateway_method.all_pokemon_options.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.options_200]
}

resource "aws_api_gateway_base_path_mapping" "domain_mapping_beatwoodmac" {
  api_id      = aws_api_gateway_rest_api.populate-pokemon.id
  stage_name  = aws_api_gateway_stage.pokemon_stage.stage_name
  domain_name = module.domain.domain_name
}

