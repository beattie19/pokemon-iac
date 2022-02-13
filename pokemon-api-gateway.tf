resource "aws_api_gateway_rest_api" "populate-pokemon-rest-api" {
  name = "populate-pokemon-rest-api"
}

resource "aws_api_gateway_resource" "populate-pokemon-resource" {
  parent_id   = aws_api_gateway_rest_api.populate-pokemon-rest-api.root_resource_id
  path_part   = "populate"
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon-rest-api.id
}

resource "aws_api_gateway_method" "populate_pokemon_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.populate-pokemon-resource.id
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon-rest-api.id
}

resource "aws_api_gateway_integration" "populate_pokemon_lambda_integration" {
  http_method = aws_api_gateway_method.populate_pokemon_get.http_method
  resource_id = aws_api_gateway_resource.populate-pokemon-resource.id
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon-rest-api.id
  type        = "MOCK"
}

resource "aws_api_gateway_deployment" "pokemon_deployment" {
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon-rest-api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.populate-pokemon-resource.id,
      aws_api_gateway_method.populate_pokemon_get.id,
      aws_api_gateway_integration.populate_pokemon_lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "pokemon_stage" {
  deployment_id = aws_api_gateway_deployment.pokemon_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon-rest-api.id
  stage_name    = "dev"
}