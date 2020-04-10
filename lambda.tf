resource "aws_iam_role" "LambdaAllowTaggingEC2Role" {
  name = "LambdaAllowTaggingEC2Role"

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

resource "aws_iam_policy" "LambdaAllowTaggingEC2Policy" {
  name        = "LambdaAllowTaggingEC2Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ],
    "Resource": "arn:aws:logs:*:*:*",
    "Effect": "Allow"
  },
  {
    "Action": [
      "ec2:CreateTags",
      "ec2:Describe*"
    ],
    "Resource": "*",
    "Effect": "Allow"
  }]
}
EOF
}



resource "aws_iam_role_policy_attachment" "LambdaTagBasedEC2RestrictionsAttachment" {
  role   = "${aws_iam_role.LambdaAllowTaggingEC2Role.id}"
  policy_arn = "${aws_iam_policy.LambdaAllowTaggingEC2Policy.arn}"
}

data "null_data_source" "lambda_file" {
  inputs = {
    filename = "/lambda/LambadaTagEC2Resources.js"
  }
}

data "null_data_source" "lambda_archive" {
  inputs = {
    filename = "${path.module}/lambda/LambadaTagEC2Resources.zip"
  }
} 

data "archive_file" "lambda" {
  type        = "zip"
  # source_file = "${data.null_data_source.lambda_file.outputs.filename}"
  source_dir  = "${path.module}/lambda"
  output_path = "${data.null_data_source.lambda_archive.outputs.filename}"
}

resource "aws_cloudwatch_log_group" "lambda_function_logging_group" {
  name = "/aws/lambda/LambadaTagEC2Resources"
}

resource "aws_lambda_function" "LambadaTagEC2Resources" {
  filename         = "${data.archive_file.lambda.output_path}"
  function_name    = "LambadaTagEC2Resources"
  role             = "${aws_iam_role.LambdaAllowTaggingEC2Role.arn}"
  handler          = "LambadaTagEC2Resources.handler"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  runtime          = "nodejs10.x"
  timeout          = 60

}


