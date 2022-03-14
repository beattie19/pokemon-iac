resource "aws_sqs_queue" "populatePokemon" {
  name                      = "populate-pokemon"
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
    redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = 1
  })
}

resource "aws_sqs_queue" "dead_letter_queue" {
  name = "populate-pokemon-DLQ"
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
