resource "aws_s3_bucket" "this" {
  bucket = "${var.app_name}-app-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.bucket
  acl    = "public-read"
  depends_on = [ 
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this
  ]
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "js_files" {
  depends_on = [aws_s3_bucket_versioning.this]
  bucket = aws_s3_bucket.this.bucket
  
  for_each = fileset(var.webapp_files, "*.js")
  key    = each.value
  source = "${var.webapp_files}/${each.value}"
  acl    = "public-read"
  etag = filemd5("${var.webapp_files}/${each.value}")
  content_type = "application/javascript"
}

resource "aws_s3_object" "html_files" {
  depends_on = [aws_s3_bucket_versioning.this]
  bucket = aws_s3_bucket.this.bucket
  
  for_each = fileset(var.webapp_files, "*.html")
  key    = each.value
  source = "${var.webapp_files}/${each.value}"
  acl    = "public-read"
  etag = filemd5("${var.webapp_files}/${each.value}")
  content_type = "text/html"
}

resource "aws_s3_object" "css_files" {
  depends_on = [aws_s3_bucket_versioning.this]
  bucket = aws_s3_bucket.this.bucket
  
  for_each = fileset(var.webapp_files, "*.css")
  key    = each.value
  source = "${var.webapp_files}/${each.value}"
  acl    = "public-read"
  etag = filemd5("${var.webapp_files}/${each.value}")
  content_type = "text/css"
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

# Cloudfront distribution
resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.this.bucket
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.this.bucket
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method = "sni-only"
  }

  aliases = ["${var.webapp_subdomain}.${var.domain_name}"]

  tags = {
    Name = "${var.app_name}-app"
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

