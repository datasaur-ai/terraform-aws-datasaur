resource "aws_s3_bucket" "vulcan" {  
  bucket = var.bucket_name

  tags = local.tags
}

resource "aws_s3_bucket_cors_configuration" "vulcan_cors" {
  bucket = aws_s3_bucket.vulcan.id

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = var.allowed_origins
    expose_headers  = []
    max_age_seconds = 31536000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "vulcan_lifecycle" {
  bucket = aws_s3_bucket.vulcan.id

  rule {
    id      = "Abort Incomplete"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "vulcan_ownership_control" {
  bucket = aws_s3_bucket.vulcan.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "vulcan_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.vulcan_ownership_control,
    aws_s3_bucket_policy.vulcan_bucket_policy
  ]

  bucket = aws_s3_bucket.vulcan.id
  acl    = "private"
}


resource "aws_s3_bucket_public_access_block" "vulcan" {
  bucket = aws_s3_bucket.vulcan.id

  depends_on = [
    aws_s3_bucket_policy.vulcan_bucket_policy
  ]

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
}

resource "aws_s3_bucket_policy" "vulcan_bucket_policy" {
  bucket = aws_s3_bucket.vulcan.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "${var.bucket_name}BucketPolicy",
    "Statement" : [
      {
        "Sid" : "${var.bucket_name}PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.vulcan.arn}/*",
      },
      {
        "Sid": "AllowSSLRequestsOnly",
        "Action": "s3:*",
        "Effect": "Deny",
        "Resource": [
            "${aws_s3_bucket.vulcan.arn}",
            "${aws_s3_bucket.vulcan.arn}/*"
        ],
        "Condition": {
            "Bool": {
                "aws:SecureTransport": "false"
            }
        },
        "Principal": "*"
      }
    ]
  })
}
