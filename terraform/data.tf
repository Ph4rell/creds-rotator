data "archive_file" "lambda_log_parser-zip" {
  type        = "zip"
  source_dir  = "../lambda/"
  output_path = "../lambda.zip"
}