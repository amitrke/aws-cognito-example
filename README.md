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
npm run build:prod
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

### Update Webapp Cognito config
Update the webapp/src/app/aws-exports.ts file with the terraform output user_pool_id, user_pool_client_id.
Build the webapp again.
Run terraform apply again to update the S3 bucket with the new webapp build.


### Access the application
Read the Cloudfront URL from the terraform output and access the application.

### Cleanup
```bash
terraform destroy --var-file=terraform.tfvars -auto-approve
```

## TODO
- DynamoDB events table time to live configuration.
- Check if there is a better way to upload the files to S3 instead of uploading first the html files then the js files and finally the css files.


aws --region=us-east-1 cognito-identity get-id `
  --identity-pool-id us-east-1:fd8ee126-c036-44f9-85c7-ec92eca4e315 `
  --logins "cognito-idp.us-east-1.amazonaws.com/us-east-1_swu99Czgc="



  aws --region=us-east-1 cognito-identity get-credentials-for-identity `
  --identity-id us-east-1:e33519eb-7cfe-cc02-495e-3e53c6ca899a `
  --logins "cognito-idp.us-east-1.amazonaws.com/us-east-1_swu99Czgc=eyJraWQiOiJzUGVkWmxoUEphZElCZUxzSlducHAwcFBRQmhrNEU3NzJ5ejRPRWJrd2RNPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoiZVB1d3lBTlJNQTBsNkZpVUtsQzNfQSIsInN1YiI6ImU0NjhmNDE4LTMwZjEtNzBlMi0yODdmLWQyNGY5MDBlYjVlYyIsImNvZ25pdG86Z3JvdXBzIjpbInVzLWVhc3QtMV9zd3U5OUN6Z2NfR29vZ2xlIl0sImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV9zd3U5OUN6Z2MiLCJjb2duaXRvOnVzZXJuYW1lIjoiR29vZ2xlXzExMzUxMDUxMDc1MDE2MDU0MTExMiIsImdpdmVuX25hbWUiOiJBbWl0IiwicGljdHVyZSI6Imh0dHBzOlwvXC9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tXC9hXC9BQ2c4b2NKV05tT19nUTluU0cyazZNVjRlT1BUdDBWNThJZWFXYUl2bUpyQ3llb1BKVjdqUV9nUk5BPXM5Ni1jIiwib3JpZ2luX2p0aSI6IjczZWRjZDNlLWVmOWEtNGM3Mi1iYzJhLWNmMzljODA1MzVjOCIsImNvZ25pdG86cm9sZXMiOlsiYXJuOmF3czppYW06Ojk3NTg0ODQ2NzMyNDpyb2xlXC9hcGlfZ2F0ZXdheV9keW5hbW9kYl9yb2xlIl0sImF1ZCI6IjE1Y2VzYnNhcW5oanFqM3NoZWttNzE3NmZiIiwiaWRlbnRpdGllcyI6W3siZGF0ZUNyZWF0ZWQiOiIxNzQ3MTA3MzUwODk3IiwidXNlcklkIjoiMTEzNTEwNTEwNzUwMTYwNTQxMTEyIiwicHJvdmlkZXJOYW1lIjoiR29vZ2xlIiwicHJvdmlkZXJUeXBlIjoiR29vZ2xlIiwiaXNzdWVyIjpudWxsLCJwcmltYXJ5IjoidHJ1ZSJ9XSwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE3NDcxMDczNTIsIm5hbWUiOiJBbWl0IEt1bWFyIiwiZXhwIjoxNzQ3MTE5MjY4LCJpYXQiOjE3NDcxMTU2NjksImZhbWlseV9uYW1lIjoiS3VtYXIiLCJqdGkiOiIyNzg5NWNmYy0xY2FiLTRkOWQtODcxMy0xOTI4ZWE5MDg3ZWMiLCJlbWFpbCI6ImFtaXRya2VAZ21haWwuY29tIn0.ICGZ2U4SKrQmz8sYka6N38_ppLWuCf_kP_M8dj9uX2t_DOkUnP5bTMdcPpTjNg7q8vFlLK2bE9q3Dv8ktnadzntyb4PT_yXRP7dlqp8xR7iLdxntGuKNJDN7cAMGnbCUVsQRNhWl_UJQQSGjxkZ7ShKPuv0jdZ1f-bI3NQeexIct92cUnOdblvVBnE5Z0q6-sJtdkuMqHTI8a7AScsEVr3u3B7V7XvcWeIb1aGmXDT4NNsLIG_C6uLhO53_nlGcwQC1DhJ-Q2zPPoR3RPN4gKMyh02VF4Z8d3nLLc4g5HeBba7TAi2V0leuiQxV4lLq5pxZ-d79BGMSEz2p0qJrGeQ"