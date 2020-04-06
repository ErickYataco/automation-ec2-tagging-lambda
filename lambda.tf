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
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "ec2:CreateTags",
        "ec2:Describe*",
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}



resource "aws_iam_role_policy_attachment" "LambdaTagBasedEC2RestrictionsAttachment" {
  role   = "${aws_iam_role.LambdaAllowTaggingEC2Role.id}"
  policy_arn = "${aws_iam_policy.LambdaAllowTaggingEC2Policy.arn}"
}

data "null_data_source" "lambda_file" {
  inputs = {
    filename = "/function/logsConsumer.js"
  }
}

data "null_data_source" "lambda_archive" {
  inputs = {
    filename = "${path.module}/function/logsConsumer.zip"
  }
} 

data "archive_file" "lambda_kinesis_stream_to_influxDB" {
  type        = "zip"
  # source_file = "${data.null_data_source.lambda_file.outputs.filename}"
  source_dir  = "${path.module}/function"
  output_path = "${data.null_data_source.lambda_archive.outputs.filename}"
}

resource "aws_cloudwatch_log_group" "lambda_function_logging_group" {
  name = "/aws/lambda/${var.LAMBDA_FUNCTION_NAME}"
}

resource "aws_lambda_function" "LambadaTagEC2Resources" {
  filename         = "${data.archive_file.lambda_kinesis_stream_to_influxDB.output_path}"
  function_name    = "${var.LAMBDA_FUNCTION_NAME}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "logsConsumer.handler"
  source_code_hash = "${data.archive_file.lambda_kinesis_stream_to_influxDB.output_base64sha256}"
  runtime          = "nodejs10.x"
  timeout          = 60

  environment {
    variables = {
      INFLUXDB_IP     = "${aws_instance.influxdb.public_ip}"
      INFLUXDB_BUCKET = "${var.INFLUXDB_BUCKET}"
      INFLUXDB_ORG    = "${var.INFLUXDB_ORG}"
      INFLUXDB_TOKEN  = "${var.INFLUXDB_TOKEN}"
    }
  }

}


