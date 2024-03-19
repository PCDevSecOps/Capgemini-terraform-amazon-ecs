/* Registry S3 bucket */
resource "aws_s3_bucket" "registry" {
  bucket = "${var.s3_bucket_name}"

  tags {
    Name = "Docker Registry"
  }
  tags = {
    yor_trace = "af1c2800-3e50-48aa-9ed9-a8f01cdb7c5e"
  }
}

/* ELB for the registry */
resource "aws_elb" "s3-registry-elb" {
  name               = "s3-registry-elb"
  availability_zones = ["${split(",", var.availability_zones)}"]

  listener {
    instance_port     = 5000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  /* @todo - handle SSL */
  /*listener {
    instance_port = 5000
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }*/

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:5000/"
    interval            = 30
  }

  connection_draining = false

  tags {
    Name = "s3-registry-elb"
  }
  tags = {
    yor_trace = "efd21d2f-ecd3-4d21-9ad5-12c316c371cf"
  }
}

/* container and task definitions for running the actual Docker registry */
resource "aws_ecs_service" "s3-registry-elb" {
  name            = "s3-registry-elb"
  cluster         = "${aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.registry.arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.ecs_role.arn}"
  depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]

  load_balancer {
    elb_name       = "${aws_elb.s3-registry-elb.id}"
    container_name = "registry"
    container_port = 5000
  }
  tags = {
    yor_trace = "0efa607e-63f1-402e-9306-f9591518f76a"
  }
}

resource "aws_ecs_task_definition" "registry" {
  family                = "registry"
  container_definitions = "${template_file.registry_task.rendered}"
  tags = {
    yor_trace = "afdc5201-914a-4fb6-aab8-f759fedef608"
  }
}
