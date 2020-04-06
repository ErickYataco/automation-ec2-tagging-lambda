resource "aws_iam_policy" "TagBasedEC2RestrictionsPolicy" {
  name        = "TagBasedEC2RestrictionsPolicy"
  path        = "/"
  //description = "My test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LaunchEC2Instances",   
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:RunInstances",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DeleteSecurityGroup",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowActionsIfYouAreTheOwner",   
      "Effect": "Allow",
      "Action": [
        "ec2:StopInstances",
        "ec2:StartInstances",
        "ec2:RebootInstances",
        "ec2:TerminateInstances",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DeletehVolume",
      ],
      "Resource": "*",
      "Condition": {
          "StringEquals":{
              "ec2:ResourceTag/Owner": "$""{aws:username}"
          }
      }
    }
  ]
}
EOF
}