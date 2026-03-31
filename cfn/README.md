# CloudFormation 스택

핸즈온에 필요한 AWS 인프라를 프로비저닝하는 CloudFormation 템플릿입니다.

## 1. github-actions-role.yaml

GitHub Actions에서 ECR에 이미지를 푸시하기 위한 OIDC Provider + IAM Role을 생성합니다.

### 배포

```bash
aws cloudformation deploy \
  --template-file cfn/github-actions-role.yaml \
  --stack-name github-actions-role-stack \
  --capabilities CAPABILITY_NAMED_IAM \
  --region <region> \
  --parameter-overrides GitHubOrg=<YOUR_GITHUB_ORG>
```

### 파라미터

| 파라미터 | 기본값 | 설명 |
|---------|--------|------|
| `GitHubOrg` | (필수) | GitHub 사용자명 또는 Organization 이름 |
| `RepoName` | `todo-app-repository` | GitHub 레포지토리 이름 |

### 주요 출력값

| 출력 | 설명 |
|------|------|
| `RoleArn` | GitHub Actions의 `AWS_ROLE_ARN` 변수에 설정할 IAM Role ARN |
| `OIDCProviderArn` | GitHub OIDC Provider ARN |

---

## 2. ingress-security-group.yaml

핸즈온 ALB용 보안 그룹을 생성합니다. AWS 오피스 및 한국 IP 대역에서만 HTTP/HTTPS 접근을 허용합니다.

### 배포

```bash
aws cloudformation deploy \
  --template-file cfn/ingress-security-group.yaml \
  --stack-name handson-sg-stack \
  --region <region> \
  --parameter-overrides VpcId=vpc-xxxxxxxx
```

### 파라미터

| 파라미터 | 기본값 | 설명 |
|---------|--------|------|
| `VpcId` | (필수) | Security Group을 생성할 VPC ID |

### 주요 출력값

| 출력 | 설명 |
|------|------|
| `SecurityGroupId` | 생성된 Security Group ID |
