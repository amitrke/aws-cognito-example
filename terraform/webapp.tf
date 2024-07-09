resource "aws_s3_bucket" "this" {
  bucket = "${var.app_name}-app-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "this" {
    bucket = aws_s3_bucket.this.bucket
    index_document {
        suffix = "index.html"
    }
    error_document {
        key = "index.html"
    }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.bucket
  acl    = "public-read"
  depends_on = [ aws_s3_bucket_ownership_controls.this ]
}

resource "aws_s3_object" "app_files" {
  for_each = fileset(path.module, "../webapp/dist/**")

  bucket = aws_s3_bucket.this.bucket
  key    = each.key
  source = "${path.module}/${each.key}"
  acl    = "public-read"
  etag = filemd5("${path.module}/${each.key}")
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}
