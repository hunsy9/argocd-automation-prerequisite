#!/bin/bash
# IAM Identity Center 사전 체크 스크립트
# 1. 기존 인스턴스 존재 여부 확인 (모든 리전 순회)
# 2. 관리 계정 여부 확인
# 3. 상황별 안내 메시지 출력

set -euo pipefail

echo "=== IAM Identity Center 사전 체크 ==="
echo ""

# 현재 계정 ID 확인
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
echo "현재 계정: ${ACCOUNT_ID}"
echo ""

# 1. 기존 인스턴스 확인 (모든 리전 순회)
echo "기존 Identity Center 인스턴스 검색 중... (모든 리전 순회)"
FOUND=false

for REGION in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do
  RESULT=$(aws sso-admin list-instances --region "$REGION" --output json 2>/dev/null) || continue
  COUNT=$(echo "$RESULT" | jq '.Instances | length')

  if [ "$COUNT" -gt 0 ]; then
    FOUND=true
    echo ""
    echo "✅ Identity Center 인스턴스 발견!"
    echo "$RESULT" | jq -r --arg region "$REGION" '.Instances[] |
      "  Region:            \($region)\n  ARN:               \(.InstanceArn)\n  Identity Store ID: \(.IdentityStoreId)\n  Status:            \(.Status // "N/A")"'
    echo "  콘솔: https://${REGION}.console.aws.amazon.com/singlesignon/home?region=${REGION}"
    echo ""
  fi
done

if [ "$FOUND" = true ]; then
  echo "이미 Identity Center가 활성화되어 있습니다. 사전 준비 가이드에 따라 사용자와 그룹을 생성해주세요."
  exit 0
fi

# 2. 인스턴스 없음 → 콘솔에서 활성화 안내
echo "🔴 Identity Center 인스턴스가 없습니다."
echo ""
echo "   사전 준비 가이드에 따라 AWS 콘솔에서 Identity Center를 활성화해주세요."
echo "   활성화 완료 후 이 스크립트를 다시 실행하여 확인하세요."
