/*
 * Amazon ECS Clusters
 *
 * http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_clusters.html
 */

resource "aws_security_group" "ecs_cluster" {
  vpc_id      = "${module.vpc.vpc_id}"
  name        = "ecs cluster"
  description = "ecs cluster (related ec2 instances) security_group"

  tags {
    Name = "ecs-cluster"
  }
}

# Using dynamic host port mapping
# http://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-load-balancing.html
resource "aws_security_group_rule" "ecs_dynamic_ports" {
  security_group_id        = "${aws_security_group.ecs_cluster.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "ecs_outbound_allow_all" {
  security_group_id = "${aws_security_group.ecs_cluster.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
