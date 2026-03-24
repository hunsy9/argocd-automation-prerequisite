#!/bin/bash
# IAM Identity Center 사전 체크 스크립트
# 1. 기존 인스턴스 존재 여부 확인 (모든 리전 순회)
# 2. 관리 계정 여부 확인
# 3. 상황별 안내 메시지 출력

set -euo pipefail

TARGET_REGION="us-west-2"

echo "=== IAM Identity Center 사전 체크 ==="
echo ""

# 현재 계정 ID 확인
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
echo "현재 계정: ${ACCOUNT_ID}"
echo ""

# 1. 기존 인스턴스 확인 (모든 리전 순회)
echo "기존 Identity Center 인스턴스 검색 중... (모든 리전 순회)"
FOUND=false
FOUND_REGION=""

for REGION in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do
  RESULT=$(aws sso-admin list-instances --region "$REGION" --output json 2>/dev/null) || continue
  COUNT=$(echo "$RESULT" | jq '.Instances | length')

  if [ "$COUNT" -gt 0 ]; then
    FOUND=true
    FOUND_REGION="$REGION"
    echo ""
    echo "⚠️  Identity Center 인스턴스 발견!"
    echo "$RESULT" | jq -r --arg region "$REGION" '.Instances[] |
      "  Region:            \($region)\n  ARN:               \(.InstanceArn)\n  Identity Store ID: \(.IdentityStoreId)\n  Status:            \(.Status // "N/A")"'
    echo ""
    break
  fi
done

if [ "$FOUND" = true ]; then
  echo "✅ 이미 Identity Center가 활성화되어 있습니다."
  if [ "$FOUND_REGION" != "$TARGET_REGION" ]; then
    echo "⚠️  단, 인스턴스가 ${FOUND_REGION}에 있습니다. 핸즈온은 ${TARGET_REGION}에서 진행됩니다."
  fi
  exit 0
fi

echo "Identity Center 인스턴스가 없습니다."
echo ""

# 2. 관리 계정 여부 확인
echo "계정 유형 확인 중..."
IS_MGMT=false

ORG_INFO=$(aws organizations describe-organization --output json 2>/dev/null) || true

if [ -n "$ORG_INFO" ]; then
  MGMT_ACCOUNT_ID=$(echo "$ORG_INFO" | jq -r '.Organization.MasterAccountId')
  if [ "$ACCOUNT_ID" = "$MGMT_ACCOUNT_ID" ]; then
    IS_MGMT=true
  fi
fi

echo ""

# 3. 상황별 안내
if [ "$IS_MGMT" = true ]; then
  echo "🔴 이 계정은 Organizations 관리 계정입니다."
  echo ""
  echo "   관리 계정에서는 CloudFormation으로 Identity Center를 생성할 수 없습니다."
  echo "   아래 단계를 따라 콘솔에서 직접 활성화해주세요:"
  echo ""
  echo "   1. AWS 콘솔 → IAM Identity Center 접속"
  echo "      https://${TARGET_REGION}.console.aws.amazon.com/singlesignon/home?region=${TARGET_REGION}"
  echo "   2. 'Enable' 버튼 클릭"
  echo "   3. 리전이 ${TARGET_REGION}인지 확인"
  echo "   4. 활성화 완료 후 이 스크립트를 다시 실행하여 확인"
else
  echo "🟢 이 계정은 standalone 또는 멤버 계정입니다."
  echo "   CloudFormation 스택으로 Identity Center를 자동 생성할 수 있습니다."
  echo ""
  echo "   다음 명령어를 실행하세요:"
  echo "   aws cloudformation deploy \\"
  echo "     --template-file cfn/identity-center.yaml \\"
  echo "     --stack-name identity-center-stack \\"
  echo "     --capabilities CAPABILITY_NAMED_IAM \\"
  echo "     --region ${TARGET_REGION}"
fi
