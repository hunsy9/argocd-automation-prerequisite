# Scripts

핸즈온 환경 사전 체크 및 설정을 위한 스크립트입니다.

## check-identity-center.sh

IAM Identity Center 사전 체크 스크립트입니다. 현재 AWS 계정의 Identity Center 상태를 확인하고 상황별 안내를 제공합니다.

### 실행

```bash
bash scripts/check-identity-center.sh
```

### 실행 결과 분기

```
시작
 │
 ├─ 모든 리전 순회하여 기존 인스턴스 검색
 │
 ├─ [인스턴스 발견] ──────────────────────────────────────────┐
 │   ✅ "이미 Identity Center가 활성화되어 있습니다"          │
 │   - 인스턴스 ARN, Identity Store ID, 리전 출력             │
 │   - 인스턴스 리전 ≠ us-west-2 이면 경고 메시지 추가       │
 │   → 종료 (추가 작업 불필요)                                │
 │                                                            │
 ├─ [인스턴스 없음] → 계정 유형 확인                          │
 │   │                                                        │
 │   ├─ [Organizations 관리 계정]                              │
 │   │   🔴 CFN으로 생성 불가                                 │
 │   │   → 콘솔에서 직접 활성화 안내                          │
 │   │     (IAM Identity Center 콘솔 URL 제공)                │
 │   │                                                        │
 │   └─ [standalone / 멤버 계정]                               │
 │       🟢 CFN으로 자동 생성 가능                            │
 │       → identity-center.yaml 스택 배포 명령어 안내         │
 │                                                            │
 └────────────────────────────────────────────────────────────┘
```

### 분기별 요약

| 상황 | 결과 | 다음 단계 |
|------|------|-----------|
| 인스턴스 이미 존재 | ✅ 정상 | 추가 작업 없음 |
| 인스턴스 없음 + 관리 계정 | 🔴 CFN 불가 | 콘솔에서 수동 활성화 |
| 인스턴스 없음 + standalone/멤버 계정 | 🟢 CFN 가능 | `cfn/identity-center.yaml` 스택 배포 |

