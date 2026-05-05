#!/usr/bin/env bash
set -euo pipefail

REGION="eu-west-1"
ALB_NAME="tech-test"
TG_NAME="tech-test"

echo ""
echo "=== Load Balancer ==="
aws elbv2 describe-load-balancers \
  --region "$REGION" \
  --names "$ALB_NAME" \
  --query "LoadBalancers[0].{DNS:DNSName,State:State.Code,Scheme:Scheme}" \
  --output table

ALB_ARN=$(aws elbv2 describe-load-balancers \
  --region "$REGION" \
  --names "$ALB_NAME" \
  --query "LoadBalancers[0].LoadBalancerArn" \
  --output text)

echo ""
echo "=== Listeners ==="
aws elbv2 describe-listeners \
  --region "$REGION" \
  --load-balancer-arn "$ALB_ARN" \
  --query "Listeners[*].{Port:Port,Protocol:Protocol,Action:DefaultActions[0].Type}" \
  --output table

TG_ARN=$(aws elbv2 describe-target-groups \
  --region "$REGION" \
  --names "$TG_NAME" \
  --query "TargetGroups[0].TargetGroupArn" \
  --output text)

echo ""
echo "=== Target Group ==="
aws elbv2 describe-target-groups \
  --region "$REGION" \
  --names "$TG_NAME" \
  --query "TargetGroups[0].{Port:Port,Protocol:Protocol,TargetType:TargetType}" \
  --output table

echo ""
echo "=== Health Check Configuration ==="
aws elbv2 describe-target-groups \
  --region "$REGION" \
  --names "$TG_NAME" \
  --query "TargetGroups[0].{Protocol:HealthCheckProtocol,Path:HealthCheckPath,Port:HealthCheckPort,ExpectedCodes:Matcher.HttpCode,IntervalSeconds:HealthCheckIntervalSeconds,TimeoutSeconds:HealthCheckTimeoutSeconds,HealthyThreshold:HealthyThresholdCount,UnhealthyThreshold:UnhealthyThresholdCount}" \
  --output table

echo ""
echo "=== Target Health ==="
aws elbv2 describe-target-health \
  --region "$REGION" \
  --target-group-arn "$TG_ARN" \
  --query "TargetHealthDescriptions[*].{Target:Target.Id,Port:Target.Port,State:TargetHealth.State,Reason:TargetHealth.Reason,Description:TargetHealth.Description}" \
  --output table
