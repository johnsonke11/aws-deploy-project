# Stock Price Tracker

A full stack, cloud-native stock price tracking application built by Kenneth Johnson. Designed to demonstrate production-grade DevOps, Cloud Automation, and SRE practices using AWS, Terraform, Docker, and Angular.

Live at: [https://johnsonke11.github.io/aws-deploy-project](https://johnsonke11.github.io/aws-deploy-project)

---

## Architecture
GitHub Pages (Angular)
↓
AWS CloudFront (HTTPS / CDN)
↓
AWS ECS Fargate (Flask API)
↓
AWS RDS PostgreSQL (Database)
↑
AWS EventBridge + Lambda (Scheduled stock fetching)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Angular 22, Chart.js, GitHub Pages |
| CDN / HTTPS | AWS CloudFront |
| Backend API | Python, Flask, SQLAlchemy |
| Database | AWS RDS PostgreSQL |
| Containerization | Docker, AWS ECR |
| Container Runtime | AWS ECS Fargate |
| Scheduler | AWS EventBridge + Lambda |
| Infrastructure | Terraform |
| Secrets | AWS Secrets Manager |
| CI/CD | GitHub Actions |
| Monitoring | AWS CloudWatch, SNS |

---

## Features

- **Live stock quotes** — fetches real time prices from Yahoo Finance via the yfinance library
- **Price history** — stores every fetch in PostgreSQL and displays the last 10 readings per ticker
- **Interactive chart** — line chart with hover tooltips showing price and timestamp built with Chart.js
- **Automated data collection** — EventBridge triggers a Lambda function every 15 minutes to fetch prices for AAPL, MSFT, NVDA, GOOGL, and AMZN automatically
- **Fully automated deployments** — every push to main triggers a full backend and frontend deployment
- **HTTPS everywhere** — CloudFront provides HTTPS termination in front of ECS
- **Alerting** — CloudWatch alarm sends an SNS email notification if the running task count drops to zero

---

## Running Locally

### Prerequisites
- Python 3.11+
- Docker Desktop
- Node.js 22+
- AWS CLI configured

### Backend

```bash
# Clone the repo
git clone https://github.com/johnsonke11/aws-deploy-project.git
cd aws-deploy-project

# Create and activate virtual environment
python -m venv venv
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run Flask app
python run.py
```

Flask runs at `http://localhost:5000`

### API Endpoints

| Endpoint | Description |
|---|---|
| `GET /health` | Health check |
| `GET /quote?ticker=AAPL` | Fetch and store current stock price |
| `GET /history?ticker=AAPL` | Return last 10 stored prices |
| `GET /dashboard` | Server rendered dashboard (Jinja2) |

### Frontend

```bash
cd angular-app
npm install
ng serve
```

Angular runs at `http://localhost:4200`

---

## Infrastructure

All AWS infrastructure is provisioned with Terraform. No resources were created manually through the console.

| File | Resources |
|---|---|
| `main.tf` | AWS provider configuration |
| `ecr.tf` | ECR container registry |
| `ecs.tf` | ECS cluster and task definition |
| `iam.tf` | IAM roles and policies |
| `networking.tf` | VPC, public subnets, internet gateway, route tables, security groups |
| `private_networking.tf` | Private subnets and RDS security group |
| `service.tf` | ECS service |
| `rds.tf` | RDS PostgreSQL instance |
| `secrets.tf` | Secrets Manager for database credentials |
| `cloudfront.tf` | CloudFront distribution |
| `eventbridge.tf` | EventBridge rule, Lambda function, IAM role |
| `monitoring.tf` | CloudWatch alarm and SNS topic |

### Provisioning

```bash
cd infra
terraform init
terraform plan -var="ecs_task_ip=YOUR_ECS_IP"
terraform apply -var="ecs_task_ip=YOUR_ECS_IP"
```

---

## CI/CD Pipeline

Every push to `main` triggers a two job GitHub Actions pipeline:

**Job 1 — Backend**
1. Build Docker image and push to ECR with commit SHA tag and latest tag
2. Force a new ECS deployment
3. Wait 60 seconds for the new task to start
4. Fetch the new ECS task public IP
5. Update CloudFront origin with the new IP via Terraform

**Job 2 — Frontend**
1. Install Node.js dependencies
2. Build Angular app for production
3. Deploy to GitHub Pages

---

## Monitoring and Alerting

A CloudWatch alarm watches the ECS `RunningTaskCount` metric. If the count drops below 1 an SNS notification is sent via email. This ensures any container crash or failed deployment triggers an immediate alert.

---

## Author

Kenneth Johnson
- GitHub: [johnsonke11](https://github.com/johnsonke11)
- Live Demo: [https://johnsonke11.github.io/aws-deploy-project](https://johnsonke11.github.io/aws-deploy-project)