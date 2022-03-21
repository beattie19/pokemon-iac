variable "pokemon_queue" {
  type = string
}

variable "max_message_size" {
  type = number
  default = 2048
}

variable "message_retention_seconds" {
  type = number
  default = 86400
}

variable "receive_wait_time_seconds" {
  type = number
  default = 10
}

variable "max_receive_count" {
  type = number
  default = 1
}
