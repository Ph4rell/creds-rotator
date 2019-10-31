provider "aws" {
  region      = "eu-west-1"
}

data "archive_file" "lambda_log_parser-zip" {
  type        = "zip"
  source_dir  = "../creds-rotator/"
  output_path = "../creds-rotator.zip"
}

resource "aws_iam_role" "role_for_lambda" {
  name              = "role_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_rotate_creds" {
  name          = "Policy4LambdaRotateCreds"
  description   = "Policy for the lambda to rotate expired IAM creds"

  policy        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ManageOwnAccessKeys",
            "Effect": "Allow",
            "Action": [
                "iam:CreateAccessKey",
                "iam:DeleteAccessKey",
                "iam:GetAccessKeyLastUsed",
                "iam:GetUser",
                "iam:ListAccessKeys",
                "iam:UpdateAccessKey",
                "iam:ListUsers",
                "ses:SendEmail",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
        "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_rotate_creds" {
  role              = "${aws_iam_role.role_for_lambda.name}"
  policy_arn        = "${aws_iam_policy.lambda_rotate_creds.arn}"
}

resource "aws_lambda_function" "lambda_rotate_creds" {
  filename          = "../creds-rotator.zip"
  function_name     = "lambda_rotate_creds"
  role              = "${aws_iam_role.role_for_lambda.arn}"
  handler           = "main.lambda_handler"
  source_code_hash  = "$data.archive_file.lambda_log_parser-zip.output_base64sha256"
  runtime           = "python3.7"
  memory_size       = "1024"
  timeout           = "60"
  publish           = "true"

  }

resource "aws_cloudwatch_event_rule" "watch_creds" {
  name                = "CloudWatch-Creds"
  description         = "EveryDay Cron to check expired IAM creds"
  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = "${aws_cloudwatch_event_rule.watch_creds.name}"
  arn       = "${aws_lambda_function.lambda_rotate_creds.arn}"
}

resource "aws_ses_email_identity" "example" {
  email = "pierre.poree@d2si.io"
}

output "version_number" {
  value = "${aws_lambda_function.lambda_rotate_creds.version}"
}

resource "aws_lambda_alias" "alias_prod" {
  name             = "Prod"
  description      = "Alias for the Prod"
  function_name    = "${aws_lambda_function.lambda_rotate_creds.arn}"
  function_version = "1"
}

resource "aws_lambda_alias" "alias_dev" {
  name             = "Dev"
  description      = "Alias for the Dev"
  function_name    = "${aws_lambda_function.lambda_rotate_creds.arn}"
  function_version = "2"
}