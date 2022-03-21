resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket_name

  force_destroy = true
}

resource "aws_s3_object" "lambda_pokemon" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = var.lambda_zip_filename
  source = data.archive_file.zip_lambdas.output_path
  etag   = filemd5(data.archive_file.zip_lambdas.output_path)
}
