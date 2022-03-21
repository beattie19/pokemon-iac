resource "aws_sqs_queue" "populatePokemon" {
  name                      = var.pokemon_queue
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
    redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_sqs_queue" "dead_letter_queue" {
  name = "${var.pokemon_queue}-DLQ"
}

resource "aws_sqs_queue_policy" "sqs_send" {
  queue_url = aws_sqs_queue.populatePokemon.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action" : [
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "${aws_sqs_queue.populatePokemon.arn}"
    }
  ]
}
POLICY
}
