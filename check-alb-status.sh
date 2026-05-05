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

echo ""
echo "=== Health Check Probe ==="
HC_PATH=$(aws elbv2 describe-target-groups \
  --region "$REGION" \
  --names "$TG_NAME" \
  --query "TargetGroups[0].HealthCheckPath" \
  --output text)

HC_PORT=$(aws elbv2 describe-target-groups \
  --region "$REGION" \
  --names "$TG_NAME" \
  --query "TargetGroups[0].Port" \
  --output text)

EXPECTED=$(aws elbv2 describe-target-groups \
  --region "$REGION" \
  --names "$TG_NAME" \
  --query "TargetGroups[0].Matcher.HttpCode" \
  --output text)

INSTANCE_ID=$(aws elbv2 describe-target-health \
  --region "$REGION" \
  --target-group-arn "$TG_ARN" \
  --query "TargetHealthDescriptions[0].Target.Id" \
  --output text)

INSTANCE_IP=$(aws ec2 describe-instances \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PrivateIpAddress" \
  --output text)

URL="http://$INSTANCE_IP:$HC_PORT$HC_PATH"
echo "  Probe URL          : $URL"
echo "  Expected HTTP code : $EXPECTED"

ACTUAL=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$URL" 2>/dev/null || echo "FAILED (connection refused or timed out)")
echo "  Actual HTTP code   : $ACTUAL"

if [[ "$ACTUAL" == "$EXPECTED" ]]; then
  echo "  Result             : OK - codes match"
else
  echo "  Result             : MISMATCH - ALB will mark this target unhealthy"
fi
