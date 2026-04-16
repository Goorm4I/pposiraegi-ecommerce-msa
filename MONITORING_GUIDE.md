# 🚀 ECS 모니터링 설정 가이드

> **완전 무료로 "진짜 프로" 인상 주는 대시보드 구축하기!**

---

## 📊 현재 구성된 모니터링

### ✅ 이미 설정된 리소스

| 리소스 | 설명 |
|--------|------|
| **Container Insights** | ECS 클러스터의 세부 메트릭 수집 (CPU/Memory/Network) |
| **CloudWatch Alarms** | 14개 알람 (CPU, Memory, ALB, Task Count) |
| **CloudWatch Dashboard** | Production Health 대시보드 (Golden Signals) |
| **SNS Topic** | `pposiraegi-alerts` 토픽 (알림 전송용) |

---

## 🎯 CloudWatch 대시보드 확인

### 1. Terraform 적용 후 대시보드 URL 확인

```bash
cd infrastructure
terraform apply

# 대시보드 URL 출력 확인
terraform output cloudwatch_dashboard_url
```

### 2. CloudWatch Console에서 대시보드 확인

1. AWS Console → **CloudWatch** → **Dashboards**
2. **`pposiraegi-production-health`** 대시보드 선택
3. 실시간 메트릭 확인!

---

## 🔔 알림 채널 설정

### Option 1: 이메일 알림 설정 (가장 간단)

```bash
# SNS 토픽 ARN 확인
export AWS_PROFILE=goorm
aws sns list-topics --query "Topics[?contains(TopicArn, 'pposiraegi-alerts')]" --output table

# 이메일 구독 추가
aws sns subscribe \
  --topic-arn arn:aws:sns:ap-northeast-2:779846782353:pposiraegi-alerts \
  --protocol email \
  --notification-endpoint your-email@example.com \
  --region ap-northeast-2
```

**확인 단계:**
1. 이메일에서 **"AWS Notification - Subscription Confirmation"** 수신
2. 이메일 내의 **"Confirm subscription"** 링크 클릭
3. 구독 완료!

---

### Option 2: Slack 알림 설정 (추천)

#### 방법 A: Slack Incoming Webhook 사용

```python
# Lambda 함수 (Slack 알림용)
import json
import urllib3
import os

def lambda_handler(event, context):
    http = urllib3.PoolManager()
    slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']
    
    # SNS 메시지 파싱
    message = event['Records'][0]['Sns']['Message']
    
    # Slack 메시지 포맷
    slack_payload = {
        "channel": "#alerts",
        "username": "AWS-Monitoring",
        "text": f"🚨 ECS Alert: {message}",
        "icon_emoji": ":warning:"
    }
    
    # Slack으로 전송
    response = http.request(
        'POST',
        slack_webhook_url,
        body=json.dumps(slack_payload),
        headers={'Content-Type': 'application/json'}
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Alert sent to Slack!')
    }
```

#### Slack Webhook 설정 단계

1. **Slack Webhook 생성**
   - Slack 워크스페이스 → **Apps** → **Incoming Webhooks**
   - **Add to Slack** 클릭
   - 알림을 받을 채널 선택 (예: `#alerts`)
   - **Add Incoming Webhooks integration** 클릭
   - **Webhook URL** 복사

2. **Lambda 함수 배포**
   ```bash
   # Lambda IAM 역할 생성
   aws iam create-role \
     --role-name pposiraegi-slack-notifier-role \
     --assume-role-policy-document '{
       "Version": "2012-10-17",
       "Statement": [{
         "Effect": "Allow",
         "Principal": {"Service": "lambda.amazonaws.com"},
         "Action": "sts:AssumeRole"
       }]
     }'
   
   # SNS 읽기 권한 부여
   aws iam attach-role-policy \
     --role-name pposiraegi-slack-notifier-role \
     --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
   
   # Lambda 함수 패키징
   zip function.zip lambda_function.py
   
   # Lambda 함수 생성
   aws lambda create-function \
     --function-name pposiraegi-slack-notifier \
     --runtime python3.11 \
     --role arn:aws:iam::779846782353:role/pposiraegi-slack-notifier-role \
     --handler lambda_function.lambda_handler \
     --zip-file fileb://function.zip \
     --environment Variables={SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL}
   
   # SNS 토픽에 Lambda 구독 추가
   aws sns subscribe \
     --topic-arn arn:aws:sns:ap-northeast-2:779846782353:pposiraegi-alerts \
     --protocol lambda \
     --notification-endpoint arn:aws:lambda:ap-northeast-2:779846782353:function:pposiraegi-slack-notifier
   ```

---

## 📈 Grafana Cloud 설정 (고급 시각화)

### Grafana Cloud 가입 및 설정 (15분)

#### 1. Grafana Cloud 계정 생성

1. [Grafana Cloud](https://grafana.com/products/cloud/) 방문
2. **"Start Free"** 클릭
3. **GitHub 계정**으로 로그인 (무료 티어)
4. 조직 이름 입력 (예: `pposiraegi`)
5. 계정 생성 완료!

#### 2. AWS CloudWatch 데이터소스 추가

```bash
# AWS IAM 유저 생성 (CloudWatch 읽기 전용)
aws iam create-user --user-name grafana-cloud-user

# IAM 정책 생성
cat > grafana-cloud-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:GetMetricData",
        "cloudwatch:DescribeAlarms"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# IAM 정책 연결
aws iam put-user-policy \
  --user-name grafana-cloud-user \
  --policy-name GrafanaCloudReadPolicy \
  --policy-document file://grafana-cloud-policy.json

# Access Key 생성
aws iam create-access-key --user-name grafana-cloud-user
```

**출력된 Access Key와 Secret Key 저장!**

#### 3. Grafana에서 CloudWatch 데이터소스 연결

1. Grafana Cloud 대시보드 → **Configuration** → **Data sources**
2. **Add data source** 클릭
3. **Amazon CloudWatch** 선택
4. 설정 입력:
   - **Name**: `AWS CloudWatch`
   - **Default Region**: `ap-northeast-2`
   - **Auth Provider**: `Access & secret key`
   - **Access Key ID**: 위에서 생성한 Access Key
   - **Secret Access Key**: 위에서 생성한 Secret Key

5. **Save & test** 클릭

---

## 📊 Grafana 대시보드 Import

### 방법 1: 공식 템플릿 Import

1. Grafana 대시보드 → **+** → **Import**
2. **Grafana.com Dashboard** 입력:
   - **ECS Fargate**: ID `551`
   - **ALB**: ID `8685`
   - **AWS Cost Explorer**: ID `8670`
3. **Load** 클릭
4. **CloudWatch** 데이터소스 선택
5. **Import** 클릭

### 방법 2: 커스텀 대시보드 JSON Import

```json
{
  "dashboard": {
    "title": "🚀 Pposiraegi Production Health",
    "uid": "pposiraegi-health",
    "tags": ["pposiraegi", "production"],
    "timezone": "browser",
    "refresh": "30s",
    "panels": [
      {
        "title": "🟢 Service Availability",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (sum(aws_applicationelb_httpcode_target_5xx_count) / sum(aws_applicationelb_request_count) * 100)",
            "legendFormat": "Availability %"
          }
        ]
      },
      {
        "title": "⚡ Response Time (P95)",
        "type": "graph",
        "targets": [
          {
            "expr": "aws_applicationelb_target_response_time",
            "legendFormat": "Response Time"
          }
        ]
      },
      {
        "title": "📊 Traffic (RPS)",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(aws_applicationelb_request_count[5m])",
            "legendFormat": "RPS"
          }
        ]
      }
    ]
  }
}
```

---

## 🎯 추천 대시보드 구성

### 1. **Golden Signals Dashboard**

| 패널 | 메트릭 | 목표 |
|------|--------|------|
| Uptime | 100 - (5XX / Total) × 100 | 99.9% |
| Latency | P95 Response Time | < 200ms |
| Traffic | Request Count | RPS 모니터링 |
| Errors | 5XX Error Rate | < 0.1% |
| Saturation | CPU/Memory Usage | CPU < 70%, Memory < 80% |

### 2. **Cost Optimization Dashboard**

| 패널 | 설명 |
|------|------|
| 월간 비용 | AWS Cost Explorer 연동 |
| 리소스 사용률 | 낭비되는 리소스 식별 |
| 최적화 기회 | 스케일 다운 권장사항 |

### 3. **Incident Response Dashboard**

| 패널 | 설명 |
|------|------|
| 현재 Alert 상황 | Active/Resolved/Suppressed |
| MTTR | 평균 장애 복구 시간 (목표: 5분) |
| 장애 히스토리 | 최근 24시간 알람 발생 |

---

## 🔍 실시간 모니터링 테스트

### 테스트 트래픽 생성

```bash
# 트래픽 생성 (데모용)
while true; do
  curl -s http://pposiraegi.cloud/api/products > /dev/null
  sleep 2
done
```

### 알림 테스트

```bash
# 수동 알람 테스트 (SNS 토픽에 메시지 전송)
aws sns publish \
  --topic-arn arn:aws:sns:ap-northeast-2:779846782353:pposiraegi-alerts \
  --message "Test: 이것은 테스트 알림입니다."
```

---

## 💰 비용 요약

| 항목 | 비용 | 설명 |
|------|------|------|
| Container Insights | ~$2-5/월 | 소규모 클러스터 |
| CloudWatch Alarms | ~$1.4/월 | 14개 × $0.10 |
| CloudWatch Logs | ~$2/월 | 예상 |
| CloudWatch Dashboard | 무료 | 기본 제공 |
| Grafana Cloud | 무료 | 14일 메트릭 보존 |
| SNS (이메일) | 무료 | 기본 제공 |
| SNS (Lambda + Slack) | ~$0.20/월 | Lambda 호출 |

**총 예상 비용**: ~$6-9/월

---

## 📚 추가 리소스

### AWS 공식 문서
- [CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html)
- [Container Insights](https://docs.aws.amazon.com/AmazonECS/latest/userguide/cloudwatch-container-insights.html)
- [ECS Service Metrics](https://docs.aws.amazon.com/AmazonECS/latest/userguide/cloudwatch-metrics.html)

### Grafana 공식 템플릿
- [ECS Fargate](https://grafana.com/grafana/dashboards/551-ecs-fargate/)
- [Application Load Balancer](https://grafana.com/grafana/dashboards/8685-aws-application-load-balancer/)
- [AWS Cost Explorer](https://grafana.com/grafana/dashboards/8670-aws-cost-explorer/)

---

## 🚨 주의사항

1. **Container Insights 활성화 시간**: ECS 서비스 재시작 필요 (약 1-2분)
2. **알림 지연**: CloudWatch → SNS → 이메일/Slack (약 1-2분)
3. **Grafana Cloud 무료 티어 제한**:
   - 14일 메트릭 보존
   - 10,000 series 제한
   - 50GB 로그 수집

---

## 🎉 완료 체크리스트

```bash
✅ Container Insights 활성화 (terraform apply)
✅ CloudWatch Alarms 생성 (14개)
✅ CloudWatch Dashboard 생성
✅ SNS 토픽 확인
✅ 이메일/Slack 알림 설정
✅ Grafana Cloud 계정 생성
✅ CloudWatch 데이터소스 연결
✅ 대시보드 Import
✅ 테스트 트래픽 생성
✅ 알림 수신 확인
```

---

**모든 설정이 완료되면 "진짜 프로 엔지니어" 대시보드 완성! 🎊**