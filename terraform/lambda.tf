resource "aws_lambda_function" "lambda" {
  filename          = "lambda.zip"
  function_name     = "creds_rotator"
  role              = aws_iam_role.lambda_role.arn
  handler           = "main.lambda_handler"
  source_code_hash  = data.archive_file.lambda_log_parser-zip.output_base64sha256
  runtime           = "python3.7"
  memory_size       = "1024"
  timeout           = "60"
  publish           = false
}

resource "aws_lambda_alias" "alias_prod" {
  name             = "Prod"
  description      = "Alias for the Prod"
  function_name    = aws_lambda_function.lambda.arn
  function_version = "1"

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