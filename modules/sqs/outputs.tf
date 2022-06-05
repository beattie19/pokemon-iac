output "queue_arn" {
  value = aws_sqs_queue.populatePokemon.arn
}

output "queue_url" {
  value = aws_sqs_queue.populatePokemon.url
} 