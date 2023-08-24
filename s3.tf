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
                "arn:aws:s3:::zain-tech-bucket/*"
            ]
        }
    ]
}
EOF

}

# uploading file to s3 bucket
resource "aws_s3_object" "index" {
  bucket = var.bucketName
  key    = "index.html"
  source = "./src/index.html"
  etag = filemd5("./src/index.html")
  depends_on = [
    aws_s3_bucket.res-bucket
  ]
}

resource "aws_s3_object" "error" {
  bucket = var.bucketName
  key    = "error.html"
  source = "./src/error.html"
  etag = filemd5("./src/error.html")
  depends_on = [
    aws_s3_bucket.res-bucket
  ]
}


# S3 website URL
output "s3-website-url" {
  value = aws_s3_bucket.res-bucket.website_endpoint
}