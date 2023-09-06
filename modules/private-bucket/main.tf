resource "aws_s3_bucket" "vulcan" {
  bucket = var.bucket_name

  tags = local.tags

}

resource "aws_s3_bucket_logging" "vulcan_logging" {
  count  = var.non_prod ? 0 : 1
  bucket = aws_s3_bucket.vulcan.id


  target_bucket = aws_s3_bucket.log_bucket[0].id
  target_prefix = "log/"

}

resource "aws_s3_bucket_ownership_controls" "vulcan_ownership_control" {
  bucket = aws_s3_bucket.vulcan.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "vulcan_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.vulcan_ownership_control]

  bucket = aws_s3_bucket.vulcan.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "vulcan_lifecycle" {
  bucket = aws_s3_bucket.vulcan.id

  rule {
    id      = "Default lifecycle rule"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }

  rule {
    id      = "Rule for export folder"
    status = "Enabled"

    filter {
      prefix = "export/"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    
    expiration {
      days = 1
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }

  rule {
    id      = "Rule for temp folder"
    status = "Enabled"

    filter {
      prefix = "temp/"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }

  rule {
    id      = "Abort Incomplete for static folder"
    status = "Enabled"

    filter {
      prefix = "static/"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_versioning" "vulcan_versioning" {
  bucket = aws_s3_bucket.vulcan.id

  versioning_configuration {
    status = var.non_prod ? "Disabled" : "Enabled"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  count  = var.non_prod ? 0 : 1
  bucket = "${var.bucket_name}-log"

  tags = local.log_bucket_tags
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket[0].id

  versioning_configuration {
    status = var.non_prod ? "Disabled" : "Enabled"
    # mfa_delete cannot be used to toggle this setting but is available to allow managed buckets to reflect the state in AWS
    mfa_delete = var.mfa_delete ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.vulcan_ownership_control]

  bucket = aws_s3_bucket.vulcan.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  count  = var.non_prod ? 0 : 1
  bucket = aws_s3_bucket.log_bucket[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "log_policy" {
  count  = var.non_prod ? 0 : 1
  bucket = aws_s3_bucket.log_bucket[count.index].id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Terraform-${aws_s3_bucket.log_bucket[count.index].id}-policy",
    "Statement": [
        {
          "Sid": "AllowSSLRequestsOnly",
          "Action": "s3:*",
          "Effect": "Deny",
          "Resource": [
              "${aws_s3_bucket.log_bucket[count.index].arn}",
              "${aws_s3_bucket.log_bucket[count.index].arn}/*"
          ],
          "Condition": {
              "Bool": {
                  "aws:SecureTransport": "false"
              }
          },
          "Principal": "*"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "vulcan" {
  bucket = aws_s3_bucket.vulcan.id

  depends_on = [
    aws_s3_bucket_policy.vulcan_bucket_policy
  ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "vulcan_bucket_policy" {
  bucket = aws_s3_bucket.vulcan.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "${aws_s3_bucket.vulcan.id}BucketPolicy",
    "Statement" : [
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

resource "aws_s3_bucket" "inventory" {
  count  = var.non_prod ? 0 : 1
  bucket = "${var.bucket_name}-inventory"

  tags = local.inventory_tags
}

resource "aws_s3_bucket_ownership_controls" "inventory_ownership_control" {
  bucket = aws_s3_bucket.inventory[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "inventory_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.inventory_ownership_control]

  bucket = aws_s3_bucket.inventory[0].id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "inventory" {
  count  = var.non_prod ? 0 : 1
  bucket = aws_s3_bucket.inventory[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "inventory_policy" {
  count  = var.non_prod ? 0 : 1
  bucket = aws_s3_bucket.inventory[count.index].id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Terraform-${aws_s3_bucket.inventory[count.index].id}-policy",
    "Statement": [
        {
            "Sid": "InventoryAndAnalyticsExamplePolicy",
            "Effect": "Allow",
            "Principal": {
                "Service": "s3.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": ["${aws_s3_bucket.inventory[count.index].arn}/*"],
            "Condition": {
                "ArnLike": {
                    "aws:SourceArn": "${aws_s3_bucket.vulcan.arn}"
                }
            }
        },
        {
          "Sid": "AllowSSLRequestsOnly",
          "Action": "s3:*",
          "Effect": "Deny",
          "Resource": [
              "${aws_s3_bucket.inventory[count.index].arn}",
              "${aws_s3_bucket.inventory[count.index].arn}/*"
          ],
          "Condition": {
              "Bool": {
                  "aws:SecureTransport": "false"
              }
          },
          "Principal": "*"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_inventory" "export_inventory" {
  count  = var.non_prod ? 0 : 1
  bucket = aws_s3_bucket.vulcan.id
  name   = "ExportInventoryDaily"

  included_object_versions = "Current"

  schedule {
    frequency = "Daily"
  }

  filter {
    prefix = "export/"
  }

  destination {
    bucket {
      format     = "CSV"
      bucket_arn = aws_s3_bucket.inventory[count.index].arn
      prefix     = "inventory"
    }
  }
  optional_fields = ["Size", "LastModifiedDate"]
}

resource "aws_s3_bucket_inventory" "static_inventory" {
  count  = var.non_prod ? 0 : 1
  bucket = aws_s3_bucket.vulcan.id
  name   = "StaticInventoryDaily"

  included_object_versions = "Current"

  schedule {
    frequency = "Daily"
  }

  filter {
    prefix = "static/"
  }

  destination {
    bucket {
      format     = "CSV"
      bucket_arn = aws_s3_bucket.inventory[count.index].arn
      prefix     = "inventory"
    }
  }

  optional_fields = ["Size", "LastModifiedDate"]
}
