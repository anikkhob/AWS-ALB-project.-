resource "aws_autoscaling_policy" "scale_up_policy" {
    name = "ScaleUpPolicy"
    autoscaling_group_name = aws_autoscaling_group.auto-SG.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = 1
    cooldown = 300 
}

# CloudWatch Alarm for scaling up
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
    alarm_name = "CPUUtilizationHigh"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"
    threshold = 50

    alarm_actions = [
    aws_autoscaling_policy.scale_up_policy.arn
    ]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.auto-SG.name
    }
}

# Auto Scaling IN Policy 
resource "aws_autoscaling_policy" "scaling-in" {
    name = "ScaleInPolicy"
    autoscaling_group_name = aws_autoscaling_group.auto-SG.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = -1
    cooldown = 300
}


# CPU Utilization Low Alarm for scaling in
resource "aws_cloudwatch_metric_alarm" "CPU_Low_Alarm" {
    alarm_name = "CPUUtilizationLow"
    comparison_operator = "LessThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"
    threshold = 50

    alarm_actions = [
        aws_autoscaling_policy.scaling-in.arn
    ]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.auto-SG.name
    }
}
