resource "aws_cloudwatch_event_rule" "AutoTagResources" {
  name        = "AutoTagResources"

  event_pattern = <<PATTERN
{
  "source": [
      "aws.ec2"
  ],  
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail":{
    "eventSource":[
      "ec2.amazonaws.com"
    ],
    "eventName":[
      "CreateImage",
      "CreateSnapshot",
      "CreateVolume",
      "RunInstances"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "AutoTagResourcesEventTarget" {
  rule      = "${aws_cloudwatch_event_rule.AutoTagResources.name}"
  target_id = "AutoTagResources"
  arn       = "${aws_lambda_function.LambadaTagEC2Resources.arn}"

  depends_on = [
      aws_lambda_function.LambadaTagEC2Resources,
  ]

}

