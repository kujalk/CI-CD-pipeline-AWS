resource "aws_sns_topic" "manual-approval" {
  name = "manual-cicd-approval"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.manual-approval.arn
  protocol  = "email"
  endpoint  = var.Email
}