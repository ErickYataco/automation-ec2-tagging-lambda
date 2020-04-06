resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"
}

resource "aws_iam_group_policy_attachment" "test-attach" {
  group      = "${aws_iam_group.group.name}"
  policy_arn = "${aws_iam_policy.TagBasedEC2RestrictionsPolicy.arn}"
}