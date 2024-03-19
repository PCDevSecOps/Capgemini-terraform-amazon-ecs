/* registry user, access key and policies */
resource "aws_iam_user" "registry" {
  name = "${var.registry_username}"
  tags = {
    yor_trace = "ac808e50-aaad-4f48-8d6c-e326ee6129ef"
  }
}

resource "aws_iam_access_key" "registry" {
  user = "${aws_iam_user.registry.name}"
}

resource "aws_iam_policy" "registry" {
  name   = "registryaccess"
  policy = "${template_file.registry_policy.rendered}"
  tags = {
    yor_trace = "d3107067-c68b-4e6c-b420-1b621358d3c4"
  }
}

resource "aws_iam_policy_attachment" "registry-attach" {
  name       = "registry-attachment"
  users      = ["${aws_iam_user.registry.name}"]
  policy_arn = "${aws_iam_policy.registry.arn}"
}

/* ecs iam role and policies */
resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = "${file("policies/ecs-role.json")}"
  tags = {
    yor_trace = "9774382f-c2a8-4194-a92e-b96f400d2ebb"
  }
}

/* ecs service scheduler role */
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = "${template_file.ecs_service_role_policy.rendered}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/* ec2 container instance role & policy */
resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name   = "ecs_instance_role_policy"
  policy = "${file("policies/ecs-instance-role-policy.json")}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/**
 * IAM profile to be used in auto-scaling launch configuration.
 */
resource "aws_iam_instance_profile" "ecs" {
  name  = "ecs-instance-profile"
  path  = "/"
  roles = ["${aws_iam_role.ecs_role.name}"]
  tags = {
    yor_trace = "ba8c8ee5-45b4-40d3-ae95-46ed1f6f1ef5"
  }
}
