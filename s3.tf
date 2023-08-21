# create bucket
resource "aws_s3_bucket" "zain-tech-bucket" {
    bucket = "zain-tech-bucket"

}

# create configuration
resource "aws_s3_bucket_website_configuration" "web-bucket-config" {
    bucket = aws_s3_bucket.zain-tech-bucket.id

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}

# # create policy
# resource "aws_s3_bucket_policy" "web-hosting" {
#     bucket = aws_s3_bucket.zain-tech-bucket.id

#     policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "PublicReadGetObject",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": [
#                 "s3:GetObject"
#             ],
#             "Resource": [
#                 "arn:aws:s3:::${aws_s3_bucket.zain-tech-bucket.id}/*"
#             ]
#         }
#     ]
# }
# POLICY
# }

# resource "aws_s3_object" "website_file" {
#   bucket = aws_s3_bucket.zain-tech-bucket.id
#   key    = "index.html"
#   source = "./src/index.html"
# }


