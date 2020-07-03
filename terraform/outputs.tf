output "version_number" {
  value = "${aws_lambda_function.lambda_rotate_creds.version}"
}
