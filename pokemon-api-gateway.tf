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

output "base_url" {
  value = aws_api_gateway_deployment.pokemon_deployment.invoke_url
}

output "populate_url" {
  value = "${aws_api_gateway_deployment.pokemon_deployment.invoke_url}/${aws_api_gateway_resource.populate-pokemon-resource.path_part}"
}


#==============================================

resource "aws_api_gateway_resource" "all-pokemon-resource" {
  parent_id   = aws_api_gateway_rest_api.populate-pokemon.root_resource_id
  path_part   = "all-pokemon"
  rest_api_id = aws_api_gateway_rest_api.populate-pokemon.id
}

resource "aws_api_gateway_method" "all_pokemon_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.all-pokemon-resource.id
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon.id
}

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
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon.id
  resource_id   = aws_api_gateway_resource.all-pokemon-resource.id
  http_method   = aws_api_gateway_method.all_pokemon_options.http_method
  status_code   = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.all_pokemon_options]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon.id
  resource_id   = aws_api_gateway_resource.all-pokemon-resource.id
  http_method   = aws_api_gateway_method.all_pokemon_options.http_method
  type          = "MOCK"
  depends_on = [aws_api_gateway_method.all_pokemon_options]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id   = aws_api_gateway_rest_api.populate-pokemon.id
  resource_id   = aws_api_gateway_resource.all-pokemon-resource.id
  http_method   = aws_api_gateway_method.all_pokemon_options.http_method
  status_code   = aws_api_gateway_method_response.options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.options_200]
}

output "all_pokemon_url" {
  value = "${aws_api_gateway_deployment.pokemon_deployment.invoke_url}/${aws_api_gateway_resource.all-pokemon-resource.path_part}"
}

# ============== ACM ============
resource "aws_api_gateway_domain_name" "beatwoodmac_domain_name" {
  domain_name              = "api.beatwoodmac.com"
  regional_certificate_arn = aws_acm_certificate_validation.beatwoodmac_cert_validation.certificate_arn
#  certificate_arn = aws_acm_certificate.beatwoodmac_cert.arn
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "domain_mapping_beatwoodmac" {
  api_id      = aws_api_gateway_rest_api.populate-pokemon.id
  stage_name  = aws_api_gateway_stage.pokemon_stage.stage_name
  domain_name = aws_api_gateway_domain_name.beatwoodmac_domain_name.domain_name
}
resource "aws_acm_certificate" "beatwoodmac_cert" {
  domain_name       = "api.beatwoodmac.com"
  validation_method = "DNS"
}

data "aws_route53_zone" "beatwoodmac_zone" {
  name         = "beatwoodmac.com"
  private_zone = false
}

resource "aws_route53_record" "beatwoodmac_record" {
  for_each = {
    for dvo in aws_acm_certificate.beatwoodmac_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.beatwoodmac_zone.zone_id
}

resource "aws_acm_certificate_validation" "beatwoodmac_cert_validation" {
  certificate_arn         = aws_acm_certificate.beatwoodmac_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.beatwoodmac_record : record.fqdn]
}
