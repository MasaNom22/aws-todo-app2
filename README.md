# TerraformでAWSへECSをデプロイ

TerraformのコードでAWS環境へECSをデプロイします。

## 構成要素
VPC  
ECR  
ECS  
ALB  
RDS  
Secrets Manager  
Remote State(S3+Dynamo DB)  
GitHub Actions CI(terraform fmt・terraform validate・tflint)  

## ディレクトリ構成

todo-web-app/  
├── .github/workflows/            # GitHub Actions用(CI)  
├── environments/  
│   ├── bootstrap/                # リモートステート(S3・DynamoDB)・OIDC Provider  
│   └── dev/                      # 開発環境  
├── modules/   
│   ├── alb/                      # ロードバランサー  
│   ├── ecr/                      # コンテナレジストリ・スキャン  
│   ├── ecs/                      # ECS Cluster・ECS task・ECS Service    
│   ├── rds/                      # DB（PostgreSQL）  
│   ├── secretsmanager/           # DBへの接続情報    
│   └── vpc/                      # VPC・IGW・Subnet・NAT Gateway   
