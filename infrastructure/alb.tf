/*
 * AWS Application Load Balancer
 *
 * http://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
 */

resource "aws_alb" "phpcon2017" {
  name                       = "phpcon2017"
  internal                   = false
  security_groups            = ["${aws_security_group.alb.id}"]
  subnets                    = ["${split(",", module.public_subnet.subnet_ids)}"]
  enable_deletion_protection = false
  idle_timeout               = 10

  # INFO: It's demo code. and no logging but your production is recommended
  #access_logs {
  #  enabled = true
  #  bucket  = ""
  #  prefix  = "alb"
  #}
}

# INFO: HTTPS is out of scope cause this is demo code.
#resource "aws_alb_listener" "https" { }

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.phpcon2017.arn}"
  port              = "80"
  protocol          = "HTTP"

  # NOTE: default_action is most low priority lister_rule
  # EX:   Another approach: Split alb for envs (canary, ...), and default as production
  default_action {
    target_group_arn = "${aws_alb_target_group.ecs.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "http_production" {
  listener_arn = "${aws_alb_listener.http.arn}"
  priority     = 100

  action {
    target_group_arn = "${aws_alb_target_group.ecs.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${var.domain}"]
  }
}

resource "aws_alb_listener_rule" "http_canary" {
  listener_arn = "${aws_alb_listener.http.arn}"
  priority     = 1

  action {
    target_group_arn = "${aws_alb_target_group.ecs_canary.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["preview-${var.domain}"]
  }
}

resource "aws_alb_target_group" "ecs" {
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = 10

  health_check {
    path                = "/ping"
    interval            = 7
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags {
    Env = "production"
  }
}

resource "aws_alb_target_group" "ecs_canary" {
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = 10

  health_check {
    path                = "/ping"
    interval            = 7
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags {
    Env = "canary"
  }
}

resource "aws_security_group" "alb" {
  vpc_id      = "${module.vpc.vpc_id}"
  name        = "alb"
  description = "application loadbalancer security_group"

  tags {
    Name = "alb"
  }
}

resource "aws_security_group_rule" "alb_http" {
  security_group_id = "${aws_security_group.alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

# INFO: HTTPS is out of scope cause this is demo code.
#resource "aws_security_group_rule" "lb_https" {
#  security_group_id = "${aws_security_group.alb.id}"
#  type              = "ingress"
#  protocol          = "tcp"
#  from_port         = 443
#  to_port           = 443
#  cidr_blocks       = ["0.0.0.0/0"]
#}

resource "aws_security_group_rule" "alb_outbound_all_allow" {
  security_group_id = "${aws_security_group.alb.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
