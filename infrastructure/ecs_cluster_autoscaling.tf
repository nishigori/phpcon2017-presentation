resource "aws_autoscaling_policy" "scale_out" {
  name                      = "${aws_ecs_cluster.phpcon2017.name}-ECSCluster-ScaleOut"
  autoscaling_group_name    = "${aws_autoscaling_group.phpcon2017.name}"
  scaling_adjustment        = 1
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = 180
}

resource "aws_autoscaling_policy" "scale_in" {
  name                      = "${aws_ecs_cluster.phpcon2017.name}-ECSCluster-ScaleIn"
  autoscaling_group_name    = "${aws_autoscaling_group.phpcon2017.name}"
  scaling_adjustment        = -1
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = 180
}

// e.g) Memory Reservation

resource "aws_cloudwatch_metric_alarm" "memory_reservation_high" {
  alarm_name          = "${aws_ecs_cluster.phpcon2017.name}-ECSCluster-MemoryReservation-High"
  alarm_description   = "${aws_ecs_cluster.phpcon2017.name} scale-out pushed by memory-reservation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = 180
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"
  alarm_actions       = ["${aws_autoscaling_policy.scale_out.arn}"]

  dimensions {
    ClusterName = "${aws_ecs_cluster.phpcon2017.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_reservation_low" {
  alarm_name          = "${aws_ecs_cluster.phpcon2017.name}-ECSCluster-MemoryReservation-Low"
  alarm_description   = "${aws_ecs_cluster.phpcon2017.name} scale-out pushed by memory-reservation-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = 180
  statistic           = "Average"
  threshold           = 15
  treat_missing_data  = "notBreaching"
  alarm_actions       = ["${aws_autoscaling_policy.scale_in.arn}"]

  dimensions {
    ClusterName = "${aws_ecs_cluster.phpcon2017.name}"
  }

  # Guard "ValidationError: A separate request to update this alarm is in progress"
  depends_on = ["aws_cloudwatch_metric_alarm.memory_reservation_high"]
}
