# CloudFormation 스택

핸즈온에 필요한 AWS 인프라를 프로비저닝하는 CloudFormation 템플릿입니다.

## 1. identity-center.yaml

IAM Identity Center(Account 인스턴스) + 테스트 그룹/유저를 생성합니다.
ArgoCD Capability에서 SSO 인증에 사용됩니다.

> ⚠️ AWS Organizations 관리 계정에서는 `AWS::SSO::Instance`를 CFN으로 생성할 수 없습니다. 콘솔에서 직접 활성화하세요.

### 배포

```bash
aws cloudformation deploy \
  --template-file cfn/identity-center.yaml \
  --stack-name identity-center-stack \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-west-2
```

### 파라미터

| 파라미터 | 기본값 | 설명 |
|---------|--------|------|
| `InstanceName` | `eks-argocd-sso` | Identity Center 인스턴스 이름 |
| `GroupName` | `testgroup` | 생성할 그룹 이름 |
| `UserName` | `testuser` | 생성할 유저 이름 |
| `UserDisplayName` | `Test User` | 유저 표시 이름 |
| `UserEmail` | `testuser@example.com` | 유저 이메일 |
| `UserFirstName` | `Test` | 유저 이름(First) |
| `UserLastName` | `User` | 유저 성(Last) |

### 주요 출력값

| 출력 | 설명 |
|------|------|
| `InstanceArn` | Identity Center 인스턴스 ARN |
| `IdentityStoreId` | Identity Store ID |
| `GroupId` | 생성된 그룹 ID |
| `UserId` | 생성된 유저 ID |

> 유저 비밀번호는 API로 설정할 수 없습니다. 스택 배포 후 Identity Center 콘솔에서 "Reset password"로 설정하세요.

---

## 2. github-actions-role.yaml

GitHub Actions에서 ECR에 이미지를 푸시하기 위한 OIDC Provider + IAM Role을 생성합니다.

### 배포

```bash
aws cloudformation deploy \
  --template-file cfn/github-actions-role.yaml \
  --stack-name github-actions-role-stack \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-west-2 \
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
