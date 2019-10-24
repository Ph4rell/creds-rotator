provider "aws" {
  region = "eu-west-1"
}

data "archive_file" "lambda_log_parser-zip" {
  type        = "zip"
  source_dir  = "../creds-rotator/"
  output_path = "../creds-rotator.zip"
}

resource "aws_iam_role" "role_for_lambda" {
  name = "role_for_lambda"

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
  name = "Policy4LambdaRotateCreds"
  description = "Policy for the lambda to rotate expired IAM creds"

  policy = <<EOF
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
                "iam:UpdateAccessKey"
            ],
        "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_rotate_creds" {
  role       = "${aws_iam_role.role_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_rotate_creds.arn}"
}

resource "aws_lambda_function" "lambda_rotate_creds" {
  filename      = "../creds-rotator.zip"
  function_name = "lambda_rotate_creds"
  role          = "${aws_iam_role.role_for_lambda.arn}"
  handler       = "main.main"
  source_code_hash = "$data.archive_file.lambda_log_parser-zip.output_base64sha256"
  runtime = "python3.7"
  }
