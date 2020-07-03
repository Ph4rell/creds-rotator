resource "aws_cloudwatch_event_rule" "watch_creds" {
  name                = "CloudWatch-Creds"
  description         = "EveryDay Cron to check expired IAM creds"
  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.watch_creds.name
  arn       = aws_lambda_alias.alias_prod.arn
}