# TerraformでAWSへリソースをデプロイ

TerraformのコードでAWS環境へリソースをデプロイします。

## 構成要素
VPC  
ECR  
Remote State(S3+Dynamo DB)  
GitHub Actions CI(terraform fmt・terraform validate・tflint)  

## ディレクトリ構成

todo-web-app/  
├── .github/workflows/            # GitHub Actions用(CI)  
├── environments/  
│   ├── bootstrap/                # リモートステート(S3・DynamoDB)・OIDC Provider  
│   └── dev/                      # 開発環境  
├── modules/   
│   ├── ecr/                      # コンテナレジストリ・スキャン  
│   └── vpc/                      # VPC・IGW・Subnet・NAT Gateway   
