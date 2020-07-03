terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region      = "eu-west-1"
}

resource "aws_lambda_function" "lambda" {
  filename          = "lambda.zip"
  function_name     = "lambda_rotate_creds"
  role              = aws_iam_role.lambda_role.arn
  handler           = "main.lambda_handler"
  source_code_hash  = data.archive_file.lambda_log_parser-zip.output_base64sha256
  runtime           = "python3.7"
  memory_size       = "1024"
  timeout           = "60"
  publish           = false

  }

resource "aws_cloudwatch_event_rule" "watch_creds" {
  name                = "CloudWatch-Creds"
  description         = "EveryDay Cron to check expired IAM creds"
  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.watch_creds.name
  arn       = aws_lambda_alias.alias_prod.arn
}

resource "aws_ses_email_identity" "example" {
  email = "pierre.poree@d2si.io"
}

resource "aws_lambda_alias" "alias_prod" {
  name             = "Prod"
  description      = "Alias for the Prod"
  function_name    = aws_lambda_function.lambda.arn
  function_version = "1"

  # A map that defines the proportion of events 
  # that should be sent to different versions of a lambda function.
  routing_config {
    additional_version_weights = {
      "2" = 0.1 # 10% of requests sent to lambda version 2
     }
  }

}

resource "aws_lambda_alias" "alias_dev" {
  name             = "Dev"
  description      = "Alias for the Dev"
  function_name    = aws_lambda_function.lambda.arn
  function_version = "$LATEST"
}