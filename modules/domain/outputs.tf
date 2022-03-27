output "api_gateway_domain_name" {
  value = aws_api_gateway_domain_name.api_domain_name.domain_name
}

output "api_gateway_zone_id" {
  value = aws_api_gateway_domain_name.api_domain_name.regional_zone_id
}

output "api_gateway_regional_domain_name" {
  value = aws_api_gateway_domain_name.api_domain_name.regional_domain_name
}
