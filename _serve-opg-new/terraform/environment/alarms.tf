data "aws_sns_topic" "alert" {
  name     = "${local.service}-${local.account.name}-app-alert"
}

data "aws_sns_topic" "alert_us_east" {
  provider = aws.us-east-1
  name     = "${local.service}-${local.account.name}-alert"
}

resource "aws_cloudwatch_metric_alarm" "alb_errors_24h" {
  alarm_name          = "${local.environment}-5xx-errors-ALB"
  statistic           = "Sum"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  period              = 86400
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  namespace           = "AWS/ApplicationELB"
  alarm_actions       = [data.aws_sns_topic.alert.arn]

  dimensions = {
    LoadBalancer = aws_lb.loadbalancer.arn_suffix
    TargetGroup  = aws_lb_target_group.frontend.arn_suffix
  }

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "response_time_24h" {
  alarm_name          = "${local.environment}-response-time"
  extended_statistic  = "p95"
  metric_name         = "TargetResponseTime"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 3
  period              = 86400
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  namespace           = "AWS/ApplicationELB"
  alarm_actions       = [data.aws_sns_topic.alert.arn]

  dimensions = {
    LoadBalancer = aws_lb.loadbalancer.arn_suffix
    TargetGroup  = aws_lb_target_group.frontend.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "errors_24h" {
  alarm_name          = "${local.environment}-5xx-errors"
  statistic           = "Sum"
  metric_name         = "HTTPCode_Target_5XX_Count"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  period              = 86400
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  namespace           = "AWS/ApplicationELB"
  alarm_actions       = [data.aws_sns_topic.alert.arn]

  dimensions = {
    LoadBalancer = aws_lb.loadbalancer.arn_suffix
    TargetGroup  = aws_lb_target_group.frontend.arn_suffix
  }

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "availability_24h" {
  provider            = aws.us-east-1
  alarm_name          = "${local.environment}-availability"
  statistic           = "Minimum"
  metric_name         = "HealthCheckStatus"
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  period              = 300
  datapoints_to_alarm = 1
  evaluation_periods  = 288
  namespace           = "AWS/Route53"
  alarm_actions       = [data.aws_sns_topic.alert_us_east.arn]

  dimensions = {
    HealthCheckId = aws_route53_health_check.homepage.id
  }
}

resource "aws_cloudwatch_log_metric_filter" "sirius_login_errors" {
  name           = "${local.environment}-serve-sirius-login-errors"
  pattern        = "\"ERROR\" \"publicapi\" \"Request ->\""
  log_group_name = aws_cloudwatch_log_group.frontend.name

  metric_transformation {
    name          = "ServeSiriusLoginErrors.${terraform.workspace}"
    namespace     = "Server/Error"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "sirius_login_errors" {
  alarm_name          = "${local.environment}-serve-sirius-login-errors"
  statistic           = "Sum"
  metric_name         = aws_cloudwatch_log_metric_filter.sirius_login_errors.metric_transformation[0].name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  namespace           = aws_cloudwatch_log_metric_filter.sirius_login_errors.metric_transformation[0].namespace
  alarm_actions       = [data.aws_sns_topic.alert.arn]
  tags                = local.default_tags
}

resource "aws_cloudwatch_log_metric_filter" "sirius_unavailable_errors" {
  name           = "${local.environment}-serve-sirius-unavailable-errors"
  pattern        = "\"NotFoundHttpException\" \"No route found for\" \"/api/passphrase\""
  log_group_name = aws_cloudwatch_log_group.frontend.name

  metric_transformation {
    name          = "ServeSiriusUnavailableErrors.${terraform.workspace}"
    namespace     = "Server/Error"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "sirius_unavailable_errors" {
  alarm_name          = "${local.environment}-serve-sirius-unavailable-errors"
  statistic           = "Sum"
  metric_name         = aws_cloudwatch_log_metric_filter.sirius_unavailable_errors.metric_transformation[0].name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  namespace           = aws_cloudwatch_log_metric_filter.sirius_unavailable_errors.metric_transformation[0].namespace
  alarm_actions       = [data.aws_sns_topic.alert.arn]
  tags                = local.default_tags
}
