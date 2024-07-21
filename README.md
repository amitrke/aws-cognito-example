# aws-cognito-example
An application that uses AWS Cognito for Authentication, API Gateway, Lambda and S3.

## Prerequisites
- AWS Account
- Terraform
- Node.js: Version 20 or higher, this is required to build the Angular application.
- Google Account for OAuth: Create a project in Google Cloud Console and enable Google+ API. Create OAuth 2.0 Client ID and download the credentials.
- Domain Name: A domain name that you own. This is required for the website to be hosted on Cloudfront and for Google OAuth.
- Route53 Hosted Zone: A hosted zone in Route53 for the domain name.
- AWS Certificate Manager: A certificate for the domain name.

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

### Create terraform.tfvars file
Create a file named terraform.tfvars in the terraform directory with the following content.

```
domain_name = "example.com"
cognito_google_client_id = "XXXXXXXX.apps.googleusercontent.com"
cognito_google_client_secret = "XXXXXXXX
certificate_arn = "arn:aws:acm:us-east-1:XXXXXXXX:certificate/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
```

### Deploy the application
```bash
cd terraform
terraform init
terraform apply --var-file=terraform.tfvars -auto-approve
```

### Access the application
Read the Cloudfront URL from the terraform output and access the application.

### Cleanup
```bash
terraform destroy --var-file=terraform.tfvars -auto-approve
```

## TODO
- Maintain terraform state in S3 and DynamoDB https://developer.hashicorp.com/terraform/language/settings/backends/s3
- Check if there is a better way to upload the files to S3 instead of uploading first the html files then the js files and finally the css files.