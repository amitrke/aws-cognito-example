# aws-cognito-example
An application that uses AWS Cognito for Authentication, API Gateway, Lambda and S3.

## Prerequisites
- AWS Account
- Terraform
- Node.js: Version 20 or higher
- Google Account for OAuth: Create a project in Google Cloud Console and enable Google+ API. Create OAuth 2.0 Client ID and download the credentials.

## Steps to run the application

### Clone the repository
```bash
git clone <repo-url>
```

### Build the application
```bash
cd webapp
npm install
npm run buildprod
cd ..
```

### Deploy the application
```bash
cd terraform
terraform init
terraform apply -auto-approve -var cognito_google_client_id="XXXXXXXX.apps.googleusercontent.com" -var cognito_google_client_secret="XXXXXXXXXX"
```

### Access the application
Read the Cloudfront URL from the terraform output and access the application.

### Cleanup
```bash
terraform destroy -auto-approve -var cognito_google_client_id="XXXXXXXX.apps.googleusercontent.com" -var cognito_google_client_secret="XXXXXXXXXX"
```

