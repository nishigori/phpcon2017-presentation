/*
 * Amazon ECS Container Service
 *
 * http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html
 */

resource "aws_ecs_task_definition" "phpcon2017" {
  family                = "phpcon2017"
  container_definitions = "${data.template_file.ecs_task_definitions.rendered}"
}

data "template_file" "ecs_task_definitions" {
  # http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  template = "${file("ecs_task_definitions.tpl.json")}"

  vars {
    region          = "${var.region}"
    docker_image    = "${aws_ecr_repository.phpcon2017.repository_url}"
    nginx_log_group = "phpcon2017/nginx"
    php_log_group   = "phpcon2017/php"
  }
}

resource "aws_ecs_service" "phpcon2017" {
  name            = "phpcon2017"
  cluster         = "${aws_ecs_cluster.phpcon2017.id}"
  task_definition = "${aws_ecs_task_definition.phpcon2017.arn}"
  iam_role        = "${aws_iam_role.ecs_service.arn}"

  # As below is can be running in a service during a deployment
  desired_count                      = "0"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "50"

  placement_strategy {
    type  = "spread" // or binpack (this module cannot specify "random"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs.arn}"
    container_name   = "nginx"
    container_port   = "80"
  }

  lifecycle {
    # INFO: In the future, we support that U can customize
    #       https://github.com/hashicorp/terraform/issues/3116
    ignore_changes = [
      "desired_count",
    ]
  }

  depends_on = ["aws_iam_role_policy.ecs_service"]
}

resource "aws_iam_role" "ecs_service" {
  name                  = "phpcon2017-ecs-service-role"
  path                  = "/"
  force_detach_policies = true
  assume_role_policy    = <<EOT
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOT
}

resource "aws_iam_role_policy" "ecs_service" {
  name   = "phpcon2017-ecs-service-policy"
  role   = "${aws_iam_role.ecs_service.name}"
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

resource "aws_cloudwatch_log_group" "ecs_nginx" {
  name              = "phpcon2017/nginx"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "ecs_php" {
  name              = "phpcon2017/php"
  retention_in_days = 3
}

// Canary Resources

resource "aws_ecs_task_definition" "phpcon2017_canary" {
  family                = "phpcon2017-canary"
  container_definitions = "${data.template_file.ecs_task_definitions_canary.rendered}"
}

data "template_file" "ecs_task_definitions_canary" {
  # http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  template = "${file("ecs_task_definitions.tpl.json")}"

  vars {
    region          = "${var.region}"
    docker_image    = "${aws_ecr_repository.phpcon2017.repository_url}"
    nginx_log_group = "phpcon2017-canary/nginx"
    php_log_group   = "phpcon2017-canary/php"
  }
}

resource "aws_ecs_service" "phpcon2017_canary" {
  name            = "phpcon2017-canary"
  cluster         = "${aws_ecs_cluster.phpcon2017.id}"
  task_definition = "${aws_ecs_task_definition.phpcon2017_canary.arn}"
  iam_role        = "${aws_iam_role.ecs_service.arn}"

  # As below is can be running in a service during a deployment
  desired_count                      = 1
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "50"

  placement_strategy {
    type  = "spread" // or binpack (this module cannot specify "random"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs_canary.arn}"
    container_name   = "nginx"
    container_port   = "80"
  }

  depends_on = ["aws_iam_role_policy.ecs_service"]
}

resource "aws_cloudwatch_log_group" "ecs_canary_nginx" {
  name              = "phpcon2017-canary/nginx"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "ecs_canary_php" {
  name              = "phpcon2017-canary/php"
  retention_in_days = 3
}
