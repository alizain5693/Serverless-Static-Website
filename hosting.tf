# create bucket
resource "aws_s3_bucket" "res-bucket" {
    bucket = var.bucketName

}


# create configuration
resource "aws_s3_bucket_website_configuration" "web-bucket-config" {
    bucket = aws_s3_bucket.res-bucket.id

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}

# make publicly accessible
resource "aws_s3_bucket_public_access_block" "no_public_block" {
  bucket = aws_s3_bucket.res-bucket.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.res-bucket.id
policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucketName}/*"
            ]
        }
    ]
}
EOF
depends_on = [
    aws_s3_bucket.res-bucket
  ]

}

# uploading file to s3 bucket
resource "aws_s3_object" "index" {
  bucket = var.bucketName
  key    = "index.html"
  source = "./src/index.html"
  etag = filemd5("./src/index.html")
  content_type = "text/html"
  depends_on = [
    aws_s3_bucket.res-bucket
  ]
}

resource "aws_s3_object" "error" {
  bucket = var.bucketName
  key    = "error.html"
  source = "./src/error.html"
  etag = filemd5("./src/error.html")
  content_type = "text/html"
  depends_on = [
    aws_s3_bucket.res-bucket
  ]
}



# create cloudfront distribution
locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default"
  description                       = "Default Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.res-bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Zain Tech Resume"
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [
    aws_s3_bucket.res-bucket
  ]
}


# OUTPUTS
# S3 website URL
output "s3-website-url" {
  value = aws_s3_bucket.res-bucket.website_endpoint
}

# CloudFront distribution domain name
output "cf-domain-name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

