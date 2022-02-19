resource "aws_lambda_function" "create_pokemon_populate_messages" {
  function_name = "createPokemonPopulateMessages"

  runtime          = "nodejs14.x"
  handler          = "createPokemonPopulateMessages.handler"
  source_code_hash = data.archive_file.zip_lambdas.output_base64sha256
  filename         = "lambda.zip"
  role             = aws_iam_role.lambda_exec.arn
}

data "archive_file" "zip_lambdas" {
  type        = "zip"
  source_dir  = "${path.module}/main/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_cloudwatch_log_group" "create_pokemon_populate_messages_cw_group" {
  name = "/aws/lambda/${aws_lambda_function.create_pokemon_populate_messages.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "stephen-pokemon-lambdas"

  force_destroy = true
}

resource "aws_s3_object" "lambda_pokemon" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda.zip"
  source = data.archive_file.zip_lambdas.output_path
  etag   = filemd5(data.archive_file.zip_lambdas.output_path)
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_pokemon_populate_messages.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.populate-pokemon.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw-all-pokemon" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_all_pokemon_from_db.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.populate-pokemon.execution_arn}/*/*"
}

# =============================================

resource "aws_lambda_function" "retrieve_and_store_pokemon_data" {
  function_name = "retrieveAndStorePokemonData"

  runtime          = "nodejs14.x"
  handler          = "retrieveAndStorePokemonData.handler"
  source_code_hash = data.archive_file.zip_lambdas.output_base64sha256
  filename         = "lambda.zip"
  role             = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role_policy" "dynamo_role_policy" {
  name = "dynamo_role_policy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:*",
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.pokemon-data.arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_lambda_event_source_mapping" "retrieve_and_store_pokemon_data" {
  event_source_arn = aws_sqs_queue.populatePokemon.arn
  function_name    = aws_lambda_function.retrieve_and_store_pokemon_data.arn
}

resource "aws_lambda_function" "get_all_pokemon_from_db" {
  function_name = "getAllPokemonFromDB"

  runtime          = "nodejs14.x"
  handler          = "getAllPokemonFromDB.handler"
  source_code_hash = data.archive_file.zip_lambdas.output_base64sha256
  filename         = "lambda.zip"
  role             = aws_iam_role.lambda_exec.arn
}